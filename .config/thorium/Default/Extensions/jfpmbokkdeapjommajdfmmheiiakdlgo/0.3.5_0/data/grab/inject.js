'use strict';

{
  // try to remove the old injected frame
  const cb = () => {
    for (const e of document.querySelectorAll('.jdFgrab')) {
      e.remove();
    }
  };
  cb();

  const dialog = document.createElement('dialog');
  dialog.addEventListener('click', () => cb());
  dialog.classList.add('jdFgrab');
  const iframe = document.createElement('iframe');
  iframe.addEventListener('click', e => e.stopPropagation());
  dialog.append(iframe);

  chrome.storage.local.get({
    width: 750,
    height: 650
  }, prefs => {
    const {width, height} = prefs;
    dialog.style = `
      width: min(80vw, ${width}px);
      height: min(80vh, ${height}px);
      border: solid 2px #e4e4e4;
      padding: 0;
      background-color: #f3f3f3;
      display: flex;
    `;
    iframe.style = `
      border: none;
      flex: 1;
    `;
    iframe.src = chrome.runtime.getURL('/data/grab/index.html?mode=' + window.mode);
    (document.body || document.documentElement).append(dialog);
    dialog.showModal();
  });
}

