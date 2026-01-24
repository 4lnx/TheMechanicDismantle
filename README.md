# 🔧 The Mechanics – Advanced Dismantle

**The Mechanics – Advanced Dismantle** adds a simple and immersive vehicle dismantling system to Project Zomboid.

Wrecked vehicles are no longer useless — if a car is badly damaged and you have the right tools, you can dismantle it and recover valuable parts.

---

## ✨ Features

* 🚗 Dismantle vehicles with **20% condition or lower**
* 📋 Dismantle option **always visible** in the context menu
* 🔒 Option is disabled if requirements are not met (with tooltip explanation)
* 🧰 Requires Blowtorch (fuel required) and Welding Mask
* 🧠 **No skill levels or magazines required**
* 🎮 Works in **Singleplayer and Multiplayer**

---

## ⚙️ How It Works

1. Right-click a vehicle
2. Select **Dismantle Vehicle**
3. The action becomes available only if:

   * Vehicle condition is ≤ 20%
   * You have a Welding Mask
   * You have a Blowtorch with enough fuel

If requirements are missing, the option will be disabled and explained via tooltip.

---

## 🔍 Vehicle Condition

Vehicle condition is calculated by:

* Checking all vehicle parts
* Comparing current condition vs maximum condition
* Generating a real overall percentage

No shortcuts, no fake values.

---

## ❓ FAQ

**Can it be added or removed from an existing save?**
Yes.

**Does it work in Multiplayer?**
Yes.

**Does it replace vanilla vehicle mechanics?**
No, it only adds dismantling functionality.

---

## 🛠️ Technical Info

* Project Zomboid **Build 42**
* Does not override vanilla vehicle menus
* No dependency on ISVehicleMenu requires
* Safe context menu handling

---

## 📜 Credits

Created by **4Lnx**
