const HOST_NAME = "com.sky1.music_bridge";

let nativePort = null;
let reconnectTimer = null;

function connectNative() {
  if (nativePort) return;

  try {
    nativePort = chrome.runtime.connectNative(HOST_NAME);

    nativePort.onMessage.addListener((message) => {
      console.debug("[Sky-1] Native host:", message);
    });

    nativePort.onDisconnect.addListener(() => {
      console.warn(
        "[Sky-1] Native host disconnected:",
        chrome.runtime.lastError?.message,
      );

      nativePort = null;

      if (reconnectTimer) {
        clearTimeout(reconnectTimer);
      }

      reconnectTimer = setTimeout(connectNative, 3000);
    });
  } catch (error) {
    console.error("[Sky-1] Native connection failed:", error);
    nativePort = null;
  }
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  if (message?.type !== "SKY1_MEDIA_UPDATE") {
    return;
  }

  connectNative();

  if (!nativePort) {
    sendResponse({ ok: false, error: "Native host unavailable" });
    return;
  }

  nativePort.postMessage({
    ...message.payload,
    tabId: sender.tab?.id ?? null,
    receivedAt: Date.now(),
  });

  sendResponse({ ok: true });
});

chrome.runtime.onStartup.addListener(connectNative);
chrome.runtime.onInstalled.addListener(connectNative);

connectNative();
