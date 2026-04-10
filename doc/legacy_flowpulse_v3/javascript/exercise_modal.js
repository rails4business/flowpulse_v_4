// app/javascript/exercise_modal.js

function youtubeIdFrom(url) {
  try {
    if (!url) return null;
    const u = new URL(url);
    if (u.hostname.includes('youtu.be')) return u.pathname.split('/').pop();
    if (u.hostname.includes('youtube.com')) {
      // supporta video normali e Shorts
      return u.searchParams.get('v') || (u.pathname.startsWith('/shorts/') ? u.pathname.split('/').pop() : null);
    }
  } catch(e) {}
  return null;
}

function parseStartSeconds(url) {
  try {
    if (!url) return 0;
    const u = new URL(url);
    // YouTube supporta t=30s o t=30
    const t = u.searchParams.get('t') || u.searchParams.get('start');
    if (!t) return 0;
    if (/^\d+$/.test(t)) return parseInt(t, 10);
    const m = t.match(/^(\d+)(s)?$/);
    if (m) return parseInt(m[1], 10);
  } catch(e) {}
  return 0;
}

function toEmbedHTML(mediaUrl) {
  if (!mediaUrl) return '';
  const yid = youtubeIdFrom(mediaUrl);
  if (yid) {
    const start = parseStartSeconds(mediaUrl);
    const startParam = start > 0 ? `?start=${start}` : '';
    return `<iframe class="w-full h-full rounded"
              src="https://www.youtube.com/embed/${yid}${startParam}"
              title="YouTube video" frameborder="0"
              allow="accelerometer; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
              allowfullscreen></iframe>`;
  }
  // fallback: immagine o qualunque URL diretto
  return `<img src="${mediaUrl}" class="w-full rounded" alt="">`;
}

document.addEventListener('turbo:load', () => {
  const modalEl = document.getElementById('exercise-modal');
  if (!modalEl || typeof window.flowbite === 'undefined') return;

  // crea/recupera istanza Modal di Flowbite
  let instance = window.flowbite?.Instances?.getInstance('Modal', modalEl);
  if (!instance) {
    // In Flowbite classica la classe è disponibile come window.Modal
    // eslint-disable-next-line no-undef
    instance = new Modal(modalEl, { backdrop: 'dynamic' });
  }

  const titleEl = document.getElementById('exercise-modal-title');
  const descEl  = document.getElementById('exercise-modal-desc');
  const mediaEl = document.getElementById('exercise-modal-media');

  document.querySelectorAll('[data-open-exercise]').forEach(btn => {
    btn.addEventListener('click', () => {
      const title = btn.getAttribute('data-title') || '';
      const desc  = btn.getAttribute('data-desc') || '';
      const media = btn.getAttribute('data-media') || '';

      titleEl.textContent = title;
      descEl.textContent  = desc;
      mediaEl.innerHTML   = toEmbedHTML(media);

      instance.show();
    });
  });
});
