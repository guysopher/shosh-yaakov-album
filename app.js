const spreadCount = 24;
const viewCount = spreadCount + 2;
const lastPageIndex = spreadCount * 2 + 1;

const pageDefinitions = [
  { src: "assets/covers/front-cover.jpg", cover: true },
  ...Array.from({ length: spreadCount }, (_, index) => {
    const number = String(index + 1).padStart(2, "0");
    return [
      { src: `assets/pages/${number}-left.jpg`, cover: false },
      { src: `assets/pages/${number}-right.jpg`, cover: false },
    ];
  }).flat(),
  { src: "assets/covers/back-cover.jpg", cover: true },
];

const reader = document.getElementById("reader");
const bookElement = document.getElementById("book");
const bookMount = document.getElementById("book-mount");
const loading = document.getElementById("loading");
const previousButton = document.getElementById("previous");
const nextButton = document.getElementById("next");
const fullscreenButton = document.getElementById("fullscreen");
const currentNumber = document.getElementById("current-number");
const totalNumber = document.getElementById("total-number");
const progress = document.getElementById("progress");
const reducedMotion = matchMedia("(prefers-reduced-motion: reduce)");

let pageFlip;
let isTurning = false;

totalNumber.textContent = String(viewCount).padStart(2, "0");

function buildPage(definition, index) {
  const page = document.createElement("div");
  page.className = `album-page${definition.cover ? " album-page--cover" : ""}`;
  page.dataset.pageIndex = String(index);
  if (definition.cover) page.dataset.density = "hard";

  const image = document.createElement("img");
  image.src = definition.src;
  image.alt = "";
  image.draggable = false;
  image.decoding = "sync";
  image.loading = "eager";
  page.appendChild(image);
  return page;
}

function waitForImage(image) {
  if (image.complete && image.naturalWidth > 0) {
    return image.decode ? image.decode().catch(() => {}) : Promise.resolve();
  }
  return new Promise((resolve, reject) => {
    image.addEventListener("load", async () => {
      if (image.decode) await image.decode().catch(() => {});
      resolve();
    }, { once: true });
    image.addEventListener("error", reject, { once: true });
  });
}

function viewIndexForPage(pageIndex) {
  if (pageIndex <= 0) return 0;
  if (pageIndex >= lastPageIndex) return viewCount - 1;
  return Math.ceil(pageIndex / 2);
}

function updateBookState(pageIndex) {
  const viewIndex = viewIndexForPage(pageIndex);
  const atFront = pageIndex <= 0;
  const atBack = pageIndex >= lastPageIndex;

  bookMount.classList.toggle("is-closed-front", atFront);
  bookMount.classList.toggle("is-closed-back", atBack);
  previousButton.disabled = atFront || isTurning;
  nextButton.disabled = atBack || isTurning;
  currentNumber.textContent = String(viewIndex + 1).padStart(2, "0");
  progress.style.width = `${(viewIndex / (viewCount - 1)) * 100}%`;
}

function setTurningState(turning) {
  isTurning = turning;
  const index = pageFlip ? pageFlip.getCurrentPageIndex() : 0;
  updateBookState(index);
}

async function initialiseBook() {
  const fragment = document.createDocumentFragment();
  pageDefinitions.forEach((definition, index) => fragment.appendChild(buildPage(definition, index)));
  bookElement.appendChild(fragment);

  const images = [...bookElement.querySelectorAll("img")];
  await Promise.all(images.map(waitForImage));

  pageFlip = new St.PageFlip(bookElement, {
    width: 1200,
    height: 1212,
    size: "stretch",
    minWidth: 260,
    maxWidth: 1200,
    minHeight: 263,
    maxHeight: 1212,
    autoSize: false,
    drawShadow: true,
    maxShadowOpacity: .48,
    flippingTime: reducedMotion.matches ? 90 : 980,
    usePortrait: false,
    showCover: true,
    mobileScrollSupport: true,
    swipeDistance: 28,
    clickEventForward: false,
    useMouseEvents: true,
  });

  pageFlip.on("flip", event => updateBookState(event.data));
  pageFlip.on("changeState", event => setTurningState(event.data !== "read"));
  pageFlip.loadFromHTML(document.querySelectorAll(".album-page"));

  updateBookState(0);
  requestAnimationFrame(() => loading.classList.add("is-hidden"));
}

previousButton.addEventListener("click", () => {
  if (!pageFlip || isTurning) return;
  pageFlip.flipPrev("top");
});

nextButton.addEventListener("click", () => {
  if (!pageFlip || isTurning) return;
  pageFlip.flipNext("top");
});

addEventListener("keydown", event => {
  if (!pageFlip || isTurning) return;
  if (["ArrowRight", "PageDown", " "].includes(event.key)) {
    event.preventDefault();
    pageFlip.flipNext("top");
  } else if (["ArrowLeft", "PageUp"].includes(event.key)) {
    event.preventDefault();
    pageFlip.flipPrev("top");
  } else if (event.key === "Home") {
    pageFlip.turnToPage(0);
    updateBookState(0);
  } else if (event.key === "End") {
    pageFlip.turnToPage(lastPageIndex);
    updateBookState(lastPageIndex);
  }
});

fullscreenButton.addEventListener("click", async () => {
  try {
    if (document.fullscreenElement) await document.exitFullscreen();
    else await reader.requestFullscreen();
    pageFlip?.update();
  } catch (_) {
    // Embedded previews may not expose fullscreen; the book remains usable.
  }
});

addEventListener("resize", () => pageFlip?.update(), { passive: true });

addEventListener("pointermove", event => {
  if (event.pointerType === "touch") return;
  const x = (event.clientX / innerWidth - .5) * 2;
  const y = (event.clientY / innerHeight - .5) * 2;
  reader.style.setProperty("--pointer-x", x.toFixed(3));
  reader.style.setProperty("--pointer-y", y.toFixed(3));
}, { passive: true });

initialiseBook().catch(error => {
  console.error("Album failed to initialise", error);
  loading.classList.remove("is-hidden");
});
