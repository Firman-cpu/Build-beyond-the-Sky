const HOST_NAME = "com.sky1.music_bridge";

let nativePort = null;
let reconnectTimer = null;

function connectNative() {
  if (nativePort) return;

  try {
    nativePort = browser.runtime.connectNative(HOST_NAME);

    nativePort.onMessage.addListener((message) => {
      console.debug("[Sky-1] Native host:", message);
    });

    nativePort.onDisconnect.addListener(() => {
      console.warn(
        "[Sky-1] Native host disconnected:",
        browser.runtime.lastError?.message,
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

browser.runtime.onMessage.addListener((message, sender) => {
  if (message?.type !== "SKY1_MEDIA_UPDATE") {
    return;
  }

  connectNative();

  if (!nativePort) {
    return Promise.resolve({
      ok: false,
      error: "Native host unavailable",
    });
  }

  nativePort.postMessage({
    ...message.payload,
    tabId: sender.tab?.id ?? null,
    receivedAt: Date.now(),
  });

  return Promise.resolve({ ok: true });
});

browser.runtime.onStartup.addListener(connectNative);
browser.runtime.onInstalled.addListener(connectNative);

connectNative();
