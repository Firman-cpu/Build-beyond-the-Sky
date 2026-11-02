(() => {
  if (window.__SKY1_BRIDGE_LOADED__) return;
  window.__SKY1_BRIDGE_LOADED__ = true;

  const browserName = "firefox";
  const SEND_INTERVAL = 2500;

  let lastPayload = "";
  let lastUrl = location.href;

  function getMeta(name) {
    return (
      document.querySelector(`meta[property="${name}"]`)?.content ||
      document.querySelector(`meta[name="${name}"]`)?.content ||
      ""
    );
  }

  function getYouTubeData() {
    if (!location.hostname.includes("youtube.com")) {
      return null;
    }

    const videoId = new URLSearchParams(location.search).get("v");

    const title =
      document
        .querySelector("ytd-watch-metadata h1 yt-formatted-string")
        ?.textContent?.trim() ||
      document.querySelector("h1.ytd-watch-metadata")?.textContent?.trim();

    const channel =
      document
        .querySelector("ytd-watch-metadata #owner #channel-name a")
        ?.textContent?.trim() ||
      document
        .querySelector("ytd-video-owner-renderer #channel-name a")
        ?.textContent?.trim() ||
      document
        .querySelector("#upload-info #channel-name a")
        ?.textContent?.trim();

    const artwork = videoId
      ? `https://i.ytimg.com/vi/${videoId}/maxresdefault.jpg`
      : "";

    return {
      title: title || "",
      artist: channel || "",
      artwork,
      extractor: "youtube",
    };
  }

  function getMediaElement() {
    const elements = [...document.querySelectorAll("video, audio")];

    return (
      elements.find((element) => !element.paused && !element.ended) ||
      elements.find((element) => element.currentSrc || element.src) ||
      elements[0] ||
      null
    );
  }

  function getMediaMetadata() {
    const session = navigator.mediaSession;
    const metadata = session?.metadata;
    const media = getMediaElement();

    const youtube = getYouTubeData();

    const artwork =
      metadata?.artwork?.find((item) => item.sizes?.includes("512x512"))?.src ||
      metadata?.artwork?.[0]?.src ||
      youtube?.artwork ||
      getMeta("og:image") ||
      getMeta("twitter:image");

    const title =
      metadata?.title ||
      youtube?.title ||
      getMeta("og:title") ||
      document.title;

    const artist =
      metadata?.artist ||
      youtube?.artist ||
      getMeta("music:musician") ||
      getMeta("author") ||
      "";

    const isPlaying = media
      ? !media.paused && !media.ended
      : session?.playbackState === "playing";

    return {
      browser: browserName,
      website: location.hostname,
      pageUrl: location.href,

      title: title || "",
      artist: artist || "",
      artwork: artwork || "",

      isPlaying: Boolean(isPlaying),

      duration: Number.isFinite(media?.duration) ? media.duration : 0,

      position: Number.isFinite(media?.currentTime) ? media.currentTime : 0,

      extractor: youtube ? "youtube" : "generic",
      timestamp: Date.now(),
    };
  }

  function sendMetadata(force = false) {
    const payload = getMediaMetadata();
    const serialized = JSON.stringify(payload);

    if (!force && serialized === lastPayload) {
      return;
    }

    lastPayload = serialized;

    browser.runtime
      .sendMessage({
        type: "SKY1_MEDIA_UPDATE",
        payload,
      })
      .catch(() => {});
  }

  const observer = new MutationObserver(() => {
    sendMetadata();
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true,
  });

  document.addEventListener("play", () => sendMetadata(true), true);
  document.addEventListener("pause", () => sendMetadata(true), true);
  document.addEventListener("loadedmetadata", () => sendMetadata(true), true);
  document.addEventListener("durationchange", () => sendMetadata(true), true);

  setInterval(() => {
    if (location.href !== lastUrl) {
      lastUrl = location.href;
      lastPayload = "";
    }

    sendMetadata();
  }, SEND_INTERVAL);

  sendMetadata(true);
})();
