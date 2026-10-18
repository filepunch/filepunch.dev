# Proposed wording for issue #68

GitLab issue filepunch/filepunch#68 lists claims on the page that the docs of the code repository qualify or contradict. The owner decides the wording, so this branch changes none of them. For each claim you find the text now, what the docs say, and one suggested replacement. When the owner has chosen, edit `site/index.html` and delete this file. This file is not published: only `site/` is.

Line numbers are for `site/index.html` on this branch. Doc paths are in the code repository, `main` as of 2026-10-18.

Three terms used below:

- **LAN endpoint**: an optional port the device can open on the local network, so a client nearby can connect without the relay (`docs/signaling.md`, "LAN signaling").
- **Mount point**: a name at the top of a share that stands for another folder on the device, such as the folder a USB stick is mounted on (`docs/protocol.md`, section 4.1).
- **TURN server**: a server that passes the encrypted traffic on when the two sides cannot reach each other directly.

## Claims to correct

### 1. "No port is opened" (step 1, line 118)

- **Now:** "A small agent on the device only connects outward. No port is opened."
- **The docs say:** the LAN endpoint is a listening port. It is off unless configured (`docs/signaling.md:62`). When it is on, it is "the device's only listening socket" (`:165`), plus a second port for finding the device on the network when `lan.mdns` is on (`:122`). The docs say to bind it to the local network and never forward it (`:68`), but nothing enforces that: `lan.listen: ":7443"` listens on every network the device is on. So the issue's "listens on the local network only" would say too much.
- **Suggested:** "A small agent on the device only connects outward. It opens no port unless you turn on the optional LAN endpoint."
- The code repository's `README.md` makes the same claim at lines 5, 46 and 156 ("no inbound ports"), so it may need the same change.

### 2. "Signed tokens bound to the client's certificate" (Locked card, line 134)

- **Now:** "Signed tokens bound to the client's certificate; paths are jailed."
- **The docs say:** the binding is optional. A token can name the client's certificate in its `fp` field, and a device refuses tokens without one only when `auth.require_fingerprint: true` is set (`docs/security.md:42`). That setting is off by default (`cmd/filepunchd/config.go:86`, `internal/auth/auth.go:249`) and commented out in `packaging/filepunchd.example.yaml:30`. The CLI, Go and TypeScript clients always send their certificate's fingerprint when they ask for a token (`docs/security.md:44`).
- **Suggested:** "Signed tokens that can be bound to the client's certificate; paths are jailed."
- The issue's other option is to keep the text and make `require_fingerprint: true` the packaged default. That is a change in the code repository.

### 3. "Works offline" (tile, line 152)

- **Now:** "A ticket fetched earlier opens a session with no internet."
- **The docs say:** a ticket (the docs call it a grant) is good for one session, and for at most `auth.max_lifetime` on the device, one hour by default (`docs/signaling.md:106`).
- **Suggested:** "A ticket fetched earlier opens one session with no internet. Tickets last up to an hour by default."

### 4. "USB sticks and SD cards" (tile, line 157)

- **Now:** "Plugged-in media appear inside the share right away."
- **The docs say:** media appear only at mount points that the device owner declares in the device configuration (`docs/protocol.md:277`). The device checks on every request, so a medium that is plugged in or removed counts from the next request, with no restart (`:283`). The issue adds that no physical medium has been tested yet.
- **Suggested:** "Media mounted at a mount point you configure appear inside the share, with no restart."

### 5. "Same network, no relay" (tile, lines 146 and 147)

- **Now:** "Finds the device on the LAN, no server needed."
- **The docs say:** browsers cannot use the LAN endpoint (`docs/signaling.md:102`); the CLI, the Go client and the TypeScript client in Node can. Only the CLI and the Go client can find the device on the network by themselves. The TypeScript client must be given the address (`:122`).
- **Suggested:** "The CLI and Go client find the device on the LAN, no server needed. The Node client connects by address."

### 6. "Coming soon" (badge above the title, line 36)

- **Now:** "Coming soon · Open source · v0.3.0 on GitHub"
- **What is true today (2026-10-18):** github.com/filepunch/filepunch is public, but it holds only a one-line README and no tags. The badge's link to the v0.3.0 tag, the "Read the protocol" button and the "Apache-2.0" link in the footer return 404.
- **Suggested:** keep "Coming soon" until the code and the v0.3.0 tag are on GitHub, then change the badge to "Open source · v0.3.0 on GitHub".

### 7. Broken sentence (line 163)

- **Now:** "Filepunch does one thing: move files to and from a device. not a sync tool, a fleet dashboard, a VPN or a cloud service, so it fits beside what you already run."
- **The problem:** the second sentence has no subject and starts with a small letter.
- **Suggested:** "Filepunch does one thing: move files to and from a device. It is not a sync tool, a fleet dashboard, a VPN or a cloud service, so it fits beside what you already run." The link stays on "not a sync tool, ... a cloud service".

## The owner's decisions

The owner chose these words knowingly. They stay unless the owner wants a change.

### 8. "No open ports, no VPN, no bytes through a server." (lead, line 38)

- The `description` and `og:description` tags (lines 8 and 13) repeat this line, so a change goes in all three places. The social card and `og:image:alt` use only the first line of the lead, so they need no change.
- **The docs say:** when no direct path works, the traffic goes through a TURN server (code `README.md:37`). It carries only encrypted data and cannot read the files (`docs/security.md:59`). "No open ports" meets the LAN endpoint point of claim 1.
- **Owner's decision.** If the owner ever wants to qualify it: "No open ports by default, no VPN, no readable bytes through a server."

### 9. "Files never do." (diagram caption, line 114) and "they talk directly" (step 3, line 120)

- **The docs say:** the same TURN point as claim 8. The caption is right about the relay it names: the signaling relay never carries files. A TURN server is a separate server.
- **Owner's decision.** The issue offers an optional addition, "(TURN fallback relays only ciphertext)". In plainer words, as a new last sentence of step 3: "If no direct path works, a TURN server passes on the encrypted data without being able to read it."

## No change needed

- "CLI · Go · browser" (diagram, line 83). The issue's own check found it correct: it labels the relay path, and browsers work there.
