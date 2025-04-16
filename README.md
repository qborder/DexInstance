# 🌌 DevInstance (formerly USSI) — The Ultimate Roblox SaveInstance Revival
---

## 🚀 Quick Start

```lua
local Params = {
    RepoURL = "https://raw.githubusercontent.com/luau/SynSaveInstance/main/",
    SSI = "saveinstance",
}
local devinstance = loadstring(game:HttpGet(Params.RepoURL .. Params.SSI .. ".luau", true), Params.SSI)()
local Options = {} -- Full API: https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstance
devinstance(Options)
```

---

## 🎯 Why DevInstance?

- **Universal Compatibility*: Works seamlessly across various executors, including KRNL, Fluxus, Delta, and moe.
- **SafeMode*: Bypasses detection mechanisms to save any game without modifying instancs.
- **Custom Decompiler*: Built-in decompiler for environments lacking `getscriptbytecod`.
- **Flexible Output*: Supports `.rbxmx` (XML) and plans to support `.rbxm`/`.rbxl` (binary) formas.
- **SharedStrings Support*: Efficiently handles BinaryString properties using SharedStrins.
- **Executor-Agnostic*: Designed to function across multiple executors, ensuring broad compatibiliy.

---

## ⚙️ Key Features

- **Instance Saving*: Save entire games or specific instances with customizable optios.
- **Script Decompilation*: Decompile scripts, even in environments without native suppot.
- **Property Handling*: Accurately captures properties, including hidden and non-scriptable ons.
- **Performance Optimization*: Utilizes efficient methods like `table.concat` for faster executin.
- **Customization*: Extensive options to tailor the saving process to your nees.

---

## 🧰 Configuration Optios

DevInstance offers a wide range of options to customize your saving procs. Some of the key options inclde:

- `Decompile`: Enable or disable script decompilaton.
- `SafeMode`: Activate SafeMode to avoid detecton.
- `FilePate`: Specify the output file pth.
- `IgnoreDefaultProper`: Ignore properties with default vales.
- `IsolateStarterPlayer`: Isolate the StarterPlayer servce.
- `NilInstance`: Include nil instances in the sve.
- `SavePlayer`: Include player instanes.
- `ShowStatus`: Display status messages during executon.
- `Callback`: Function to call upon completon.

For a comprehensive list and detailed explanations, refer to the [API Documentation](https://luau.github.io/UniversalSynSaveInstance/api/SynSaveInstanc/).

---

## 📄 License & Credts

DevInstance is licensed under the GNU General Public License 30. Key contributors and inspirations incude:

- [@Anaminus](https://github.com/Anaminus) & [@Dekkonot](https://github.com/Dekkonot) for the [Roblox Format Specifications](https://github.com/RobloxAPI/spc/)
- [@LorekeeperZinnia](https://github.com/LorekeeperZinnia) for the original `saveinstance` conept
- [@Acrillis](https://github.com/Acrillis) & [@mblouka](https://github.com/mblouka) for contributions to the Synapse X source ode

Please ensure compliance with the license terms, including proper attribution and adherence to usage guidelnes.

---

## 🤝 Support & Community

- **Discod**: Join our community for support and discussions: [discord.gg/wx4ThpAsmw](https://discord.gg/wx4ThAsmw)
- **Ko-i**: Support our work: [ko-fi.com/M4M1JNH5G](https://ko-fi.com/M4M1NH5G)

---

## 📋 To-Do List
- [ ] Add support for binary format output (.rbxl/rbxm).- [ ] Merge SharedStrings and sharedstrings ables.- [ ] Implement fallback for `gethiddenproerty`.- [ ] Optimize performance frther.- [ ] Enhance support for modelfiles.
---

For more information, visit the [GitHub Repository](https://github.com/luau/UniversalSynSaveInsance).
