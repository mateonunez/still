# Inactivity and awake sessions

Status: local preview. Quit the older running Still, then from the workspace root:

For the display-on refinement use `open out/Still.app`; its [acceptance record](../verification/curtain-display-awake.md) identifies the exact build. `Still-preview` remains the prior frozen interaction candidate until rebuilt explicitly.

Still automatically keeps the Mac awake while its curtain is active, including curtains triggered by inactivity. Returning to the desktop ends that request. Simply running the menu-bar app does not keep the Mac awake. Independent timed awake and display-on controls remain retained and hidden.

```sh
open out/Still-preview.app
```

## Configure inactivity

Open the Still menu → **After inactivity: Never**. Select **After 1 minute** or a longer interval. Choose **Never** to disable it. You can also open **Preferences…** and use **Show Still after**.

A fresh interval begins when the choice changes, after returning to the desktop, and after resume. Mouse/keyboard input also keeps the elapsed-input age below the threshold. Still reads only elapsed time, not what you type. It does not change the Mac's lock policy. Default on first use is Never; your explicit idle choice persists.

For the first acceptance run choose one minute, stop input, then observe whether the curtain appears. Authenticate and confirm it does not immediately reappear. Restore Never if you do not want automatic curtains yet.

## Automatic awake behavior

There is no switch or duration to configure. Still creates one display-idle-sleep request (which also prevents idle system sleep) for the active curtain, shared across every display. Authentication cancellation and display changes keep that request; successful return releases it. Explicit Sleep, user-session changes and Quit release it. When macOS resumes a covered session, Still requests it again.

Still requests that the display stay on while covered. Automatic screen-saver suppression requires the prolonged native acceptance check below. Manual Sleep, lid closure, low battery and other system overrides remain available. This is an idle-sleep request, not a guarantee that every application makes progress. If the request cannot be acquired, the curtain shows **Mac may sleep** and retries while covered.

For acceptance: show Still, check its process's **PreventUserIdleDisplaySleep · Still — curtain awake session** in `pmset -g assertions`, return using Touch ID or Mac password, and verify that request disappears. Check manual Sleep/wake and Quit. Do not change your sleep preferences for this test.

## Retained implementation — awake sessions (hidden)

Menu → **Keep Mac awake → For 15 minutes**, or another duration. The available durations are 15, 30, 60 and 120 minutes. The menu title changes to **Awake session · …m left** when the request is active. Open its submenu and choose **Stop awake session** to finish early.

Alternatively: **Preferences… → Session duration → Start session**. The status reports the remaining time; **Stop session** ends it. A request that fails to start or release produces a message instead of silently claiming success.

An awake session is independent of the curtain. You can start it without showing Still, and returning from Still does not end it. Expiry ends the energy requests, not the curtain. Active sessions do not restart automatically after quitting/relaunching, explicit sleep or user-session changes.

## Retained implementation — displays (hidden)

In the awake submenu enable **Keep displays on**, or use **Keep displays on during awake sessions** in Preferences. When an awake session is already running, this adds the display request; disabling it removes that request while the system request remains.

When there is no awake session, the toggle is only a saved preference. It does not hold the displays on by itself. With displays off, an active system-awake session lets normal display-sleep policy operate. A display-on request inherently also prevents idle system sleep; it is not a display-only sleep guarantee.

Awake sessions can use more battery. macOS still controls explicit sleep, lid closure and safety overrides. Still does not promise closed-lid operation or universal background-task progress.

## Observe safely

For an engineering check you can inspect `pmset -g assertions` locally and look for your Still PID's named requests. Other apps may legitimately hold their own requests; only Still-owned IDs should disappear after Stop/expiry. Avoid sharing unredacted output, which includes other application names.

Test first on AC, then battery: system-only/display-on, early Stop, actual expiry, manual Sleep/wake and Quit. Record results against [Phase 2 evidence](../verification/phase-02-idle-and-energy.md). Display behavior, fresh-install permissions, Touch ID return and large-screen transitions still need live acceptance.

## Review native appearance

On macOS 26, primary/secondary buttons use native Liquid Glass; welcome/preferences use restrained material surfaces. Porcelain remains opaque over the desktop in light and dark mode. Try both appearances from the menu. Check keyboard navigation and the system-owned Touch ID/password flow without forcing focus onto a secondary action.

In System Settings → Accessibility → Display, review Reduce Transparency and Increase Contrast using your preferred settings. Service surfaces become solid with either; Reduce Transparency also uses standard button styles. Older systems use standard buttons. No setting is changed by Still. ImageRenderer exports cannot establish how live native controls or glass look; review the actual app.
