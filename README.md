# **⬆️ BEMEUP** (Prototype)

<p align="center" style="background:black;display:inline-block; padding:20px 30px">
  <img src="https://raw.githubusercontent.com/gist/cimdatapaw/cb7e978bbe0809aa823c4547e12c1e92/raw/211e73d21d5f76900bc7f7c39baec83453b89114/logo.svg" width="600"/>
</p>

    Powered by Bemeow (Beats of Meow)
    Contribution to BONK Startup Building Challenge 2025
    All Rights Reserved – Usage requires explicit permission from the author.

---

### **👉 Try the Prototype:** https://bemeow-test.web.app

---

<img src="/screenshots/phone_outro.png" height="250px" hspace="10"><img src="/screenshots/phone_boost.png" height="250px" hspace="10"><img src="/screenshots/phone_create.png" height="250px" hspace="25">

---

<img src="/screenshots/phone_fungible.png" height="250px" hspace="10"><img src="/screenshots/phone_collectible.png" height="250px" hspace="35"><img src="/screenshots/phone_payment.png" height="240px" hspace="10">

---

***redeployment from: https://github.com/sbc-25/bemeup-prototype***

---

## **😺 WHAT IS BEMEUP?**

### **ℹ️ Basic Info**

- **BemeUp** is a Social Media App for interactive Music Events
- **Mobile-First:** Android, iOS & Web
- **Languages:** Frontend: Dart (Flutter), Backend: Typescript
- **Platform:** Firebase / GCP
- **Database:** Realtime DB (US)
- **File Hosting:** Storage Bucket (US)
- **Backend Hosting:** v2 Cloud Functions (Docker Container by Design)
- **VM for Prototype:** e2-Micro (min/max 2 Instances)


### **🎯 Main Objectives**
- Crowd-Driven Music & Events (Realtime Personalization)
- Increase Revenue for Artists, DJs & Real Fans
- Drive Web3 Mass Adoption (Usage at Festivals & Night Clubs)
- Become a leading Platform for DJs, Artists & Fans Worldwide

### **✨ Key Features**
<details>
<summary>(click to open)</summary>

- **USP:** Crowd can Vote-4-Free or Pay-2-Boost Songs in Ranking & Spotlight of Stage
- **USP:** Collected Credits from Pay-2-Boost finance Rewards for DJ, Artist & Payers
- **USP:** Proof-of-Play (PoP) via Audio Recognition stored On-Chain & triggers Rewards
- **Vertical:** Upload Songs or Create with AI to boost them to Events worldwide
- **Vertical:** Automated Distribution & Royalty Collection for User-Generated Music
- **Vertical:** Fungible & Collectible Song Tokenization, Launchpads & Trading
- **Vertical:** Fungible Token Taxes finance more Artist & NFT Holder Rewards
- **Vertical:** Social Media Concept to drive Engagement with Users & Functions 

</details>

### **🔑 Core Principles**
<details>
<summary>(click to open)</summary>

- **Gamified UX:** Playful Spending of Credits Micro-Taps (Freemium)
- **Brand Experience:** Customizable Design Feeling for Pages: User Profile, Songs, Event, Stage
- **Conversion-Friendly:** Streaks, Activity Rewards & Eliminating Onboarding Barriers
- **Newbie-Friendly:** Web3 as an Option (Incentives, Gradual Onboarding, Rug-Prevention)
- **Nightlife Design:** Modern Futuristic Electronic Music Feel and Dark Mode First Approach
- **Simplicity:** Intuitive Navigation and No Information Overload
- **Resilience:** to Technology & Market Dynamics (Adopt new Tech & Trends)
</details>
<br>

---

## **🔍 PROTOTYPE FOR SBC**

### ⚙️ **Paradigms**
- **Target Application** Multi-faceted and quite complex
- **Prototype Purpose** Showcasing the UI 
- **Result-Driven:** Maximum Output within SBC Deadline 
- **Therefore:** Quantity & Design supersedes Best Practise

### 🚧 **Limits**
- **Devices:** Web + Device Preview (no APK yet)
- **Modes:** Portrait & Dark
- **Data:** Dummy / Placeholders
- **DB Access:** Read only
- **Languages:** EN (default) & DE
- **Placeholders:** Some Pages / Tabs / Widgets

### ✅ **Included** (Frontend)
<details>
<summary>(click to open)</summary>

- Menu, Navigation & Simple Page-Routing
- Simple & Modern Music Player
- Start Page: Tabs, Recommendations, opportunities
- Create Page: Form to generate AI Music
- User Profiles: Avatar, Background, Basic Info, Songs, Likes
- Song Pages: Coverart, Basic Info, Comments, Likes, Lyrics
- Event Pages: Event List, Stages, Details
- Stage Pages: Song Ranking & Spotlight, Pay-2-Boost
- Wallet Page (Web2): Credit & Earnings Balance
- Buy & Pay: Topup Credits, Payment Methods, Upgrade & Compare Plans
- Timezone & Language Recognition
- Mini-Popup for Quick-Info (e.g. insufficient credits, no license etc)
- Logged Simulation (Dummy UUID)
- Redirect to Start Page on 404

</details>

<br>

### ⚠️ **Issues** (TBD)
<details>
<summary>(click to open)</summary>

- Web performance to be optimized
- Sometimes player doesn't reload waveform
- Style Parameter Redundancies
- Image caching not yet applied everywhere
- Routing of missing UUID-Slugs to Start Page
- Remaining Tooltips & Translations
- Unique Tooltip Keys & onTap for Native
- Missing Units for Values in "Plans" Page
- Text Length Capping & Reveal for dynamic Content
- Hardcoded Vertical Page Lengths to be made dynamic
- Pin Spotlights to Top (suppress vertical scroll)
- More Space around Tap-Elements

</details>

<br>

### 🟡 **Not yet included** (but done in %)
*Remaining % are mostly adjustments for smooth integration*

<details>
<summary><b>Backend</b> (click to open)</summary>

- **(95%)** Webhook for Post Requests (Express JS)  
- **(20%)** Commands Router with Dynamic Params  
- **(95%)** Centralized & Dynamic Retry Logic  
- **(95%)** Centralized Separation of Await vs. Fire & Forget  
- **(95%)** IP Rate Limits  

</details>

<br>

<details>
<summary><b>Web3</b> (click to open)</summary>

- **(100%)** BEME Token TGE & Liquidity Pools in SOL & USDC  
- **(95%)** Token Deployment Modules (SPL & Token2022 + Transfer Fee)  
- **(95%)** Batch Transactions (Tokens & SOL)  
- **(95%)** Authority Revocation (Update, Mint, Freeze, Transfer Fee Config)  
- **(95%)** Minting, Burning, Account Closing, Vanity Addresses  
- **(90%)** Song & Album Tokenization with Music Metadata & Irys Storage  
- **(85%)** RPC Methods (Quicknode): Balance Checks, Tx Status, Fee Estimation etc  
- **(95%)** On-Chain Referrals for Launchpads using the Solana Memo Program  

</details>

<br>

<details>
<summary><b>Music</b> (click to open)</summary>

- **(90%)** Bemeow Bot API: Quality & Accuracy Optimization of AI Music
- **(95%)** Bemeow Bot API: AI Lyrics in 95+ Languages
- **(95%)** Bemeow Bot API: User Support Assistant in 60+ Languages
- **(100%)** Artist Name Availability Checker 
- **(95%)** Artist Name Creator Business Logic 
- **(90%)** SVG Generator for Music Waveforms
- **(90%)** User Profile Background & Avatar Generator 
- **(90%)** Custom & 3rd Party Song Recognition via ACR Cloud
- **(80%)** Share on X Function (Dynamic HTML Header for Thumbnails to be added)

</details>

<br>

### ❌ **Not included** (TBD for MVP)

<details>
<summary>(click to open)</summary>

- User Rate Limits
- Security Token Rotation
- Playlists Page: Only Placeholder
- Web2 Payment Providers with PCI DSS Compliance
- SignUp: Google, Apple, Phone (E-Mail SignUp not planned)
- Suggest Song to Ranking
- Edit Profile & Account Preferences
- UUID-Slugs for identified Page-Routing
- Filter / Search Function for Events, Users & Songs
- Functions for Following, Liking, Commenting, Messaging
- Follower/Following Lists
- Extended Player Controls (Repeat, Shuffle, Prev/Next, Volume)
- Upload, Download, Remix & Remaster Functions
- 3rd Party Music Metadata API
- Image-2-Song Function
- Automated Audio Mastering
- Event-Check-In via QR-Code
- Ticket Vendor API & Referral Codes
- Client Side Transactions & Wallet Connection with Espresso Cash
- Peer-2-Peer Web3 Payment (without Connecting Wallet)
- Web2 Payment Provider API & Merchant Account
- Trading View Integration for fungible Music Tokens
- Web3: NFT Deployment & Management via Metaplex
- Cross-Platform Automation: Soundcloud, TikTok, X, Spotify
- Revelator API: Automated Music Distribution & Royalty Splitting 
- Automated Commissioning of Vinyl Record Production & Delivery
- Tagging of AI Music Lyrics
- Launchpad UI, User & Wallet Stats
- Use of Emojis in Language List for Song Creation
- and more

</details>

<br>


---

# **🔗 Links**

## **📁 SBC Files**
- [Business Model Canvas](https://drive.google.com/file/d/1fXHbwl4-Jp6yQvxmDNBhdeCtHbCkh4O8/view?usp=drive_link)
- [Pitch Video](https://drive.google.com/file/d/1d8Z_Xn4o2sVROJLKIMXZjPB4F1G6fdKr/view?usp=sharing)

## **❤️ Team @LinkedIn**
- [Ramón Szellatis (Founder)](https://de.linkedin.com/in/ramon-szellatis)
- [Jan Münter (Manager)](https://www.linkedin.com/in/jan-m%C3%BCnter-4a0906169)
- [Loi Finke (Co-Dev)](https://www.linkedin.com/in/loi-finke-a04174216)

<!-- 
## **😽 Bemeow**
- [Website](https://bemeow.club)
- [Linktree](https://linktr.ee/beatsofmeow)
- [Telegram](https://t.me/beatsofmeow) (incl. Bemeow Music Bot)
- [X/Twitter](https://x.com/bemeowrecords)
- [Bemeow dApp](https://app.bemeow.club) (post-presale)
- [BONK Integration in dApp](https://drive.google.com/file/d/1Xk8oO9fn3LIMF6hcFOwbksJRRqph1mBB/view?usp=sharing) (Q4/2024)
- [CA:](https://solscan.io/token/BEMEeJ8sSyQXswNiZ98M8ppyJGDE4g5UumqgZkANNVbb) BEMEeJ8sSyQXswNiZ98M8ppyJGDE4g5UumqgZkANNVbb
- [BEME Chart](https://dexscreener.com/solana/epbwjmhfyvnwdkjbztm8dmjqpo9opjysinmucq7dbzck) (6/20 Vestings)
 -->

## **🎵 Tokenization Example:**
- [Album](https://solscan.io/token/Audio2gzgkhyvbFhLCVgdsMK4dwvCrNQP1z1ijVNTiLy#extensions)
- [1 Song of Album](https://solscan.io/token/MP3LJTvmbBRdiuLVDrTLqd3EEjg4uvJnoMyLVCBxdP2#extensions)
- [Asset](https://solscan.io/token/FEETHbYTHd6yzmhizNAPTYU1qyR1JteR6JLsjm4rxZSf#extensions)
- [Remix Copyright for Holders](https://solscan.io/token/MCA4aDHuxWBm9BNtRQeWhfDMPpecjfSYkbD3xKS3FK9#extensions)

---

