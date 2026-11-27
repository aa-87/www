(() => {
  "use strict";
  const $ = id => document.getElementById(id);
  const command = $("command"), transcript = $("transcript"), terminal = $("terminal");
  const greeting = "MUMPS.IO / native routine console\nType help or select an example.\n";
  let term = null, busy = false, lines = [];
  function append(value) {
    const safe = String(value).replace(/[^\x20-\x7e\n]/g, "?");
    lines.push(safe.slice(0, 2048)); if (lines.length > 80) lines.shift();
    transcript.textContent = lines.join("\n");
    if (term) { term.reset(); term.write(lines.join("\r\n").replace(/\r?\n/g,"\r\n")); }
    terminal.scrollTop = terminal.scrollHeight;
  }
  function reset() { lines = []; append(greeting); }
  // Reuse the self-hosted MIOOS xterm assets if installed; accessible transcript remains available.
  if (typeof window.Terminal === "function") {
    try {
      const surface = document.createElement("div");
      surface.setAttribute("aria-hidden", "true");
      terminal.append(surface);
      term = new window.Terminal({cols: Math.max(24,Math.min(76,Math.floor(terminal.clientWidth / 9)-2)),rows:11,disableStdin:true,scrollback:100,theme:{background:"#18211c",foreground:"#d5e8d4"}});
      term.open(surface);
      transcript.style.position = "absolute"; transcript.style.width = "1px"; transcript.style.height = "1px"; transcript.style.overflow = "hidden";
      window.addEventListener("resize",()=>term.resize(Math.max(24,Math.min(76,Math.floor(terminal.clientWidth / 9)-2)),11));
    } catch (_) { term = null; }
  }
  reset();
  $("console").addEventListener("submit", async e => {
    e.preventDefault(); if (busy) return;
    const value = command.value;
    if (!/^[\x20-\x7e]{1,256}$/.test(value)) { append("Input must be 1–256 printable ASCII characters."); return; }
    busy = true; $("console").querySelector("button").disabled = true;
    append("M> " + value);
    const controller = new AbortController(), timer = setTimeout(()=>controller.abort(),8000);
    try {
      const response = await fetch("/lab/run",{method:"POST",headers:{"Content-Type":"text/plain;charset=UTF-8"},body:value,credentials:"omit",cache:"no-store",signal:controller.signal});
      const data = await response.json();
      append(response.ok && String(data.ok)==="1" ? data.output : "Error: " + (data.error || response.status));
    } catch (_) { append("Console unavailable. Check connection and try again."); }
    finally { clearTimeout(timer); busy=false; $("console").querySelector("button").disabled=false; }
  });
  document.querySelectorAll("[data-command]").forEach(button=>button.addEventListener("click",()=>{command.value=button.dataset.command;command.focus();}));
  $("clear").addEventListener("click",reset);
  $("filter").addEventListener("input",e=>{
    const query=e.target.value.toLowerCase(); let visible=0;
    document.querySelectorAll("[data-routine]").forEach(item=>{item.hidden=!item.textContent.toLowerCase().includes(query);if(!item.hidden)visible++;});
    $("no-results").hidden=visible!==0;
  });
  const root=document.documentElement;
  try { const theme=localStorage.getItem("mio-theme"); if(theme==="dark"||theme==="light")root.dataset.theme=theme; } catch (_) {}
  $("theme").addEventListener("click",()=>{root.dataset.theme=root.dataset.theme==="dark"?"light":"dark";try{localStorage.setItem("mio-theme",root.dataset.theme);}catch(_){}});
})();