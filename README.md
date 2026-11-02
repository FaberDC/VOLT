# VOLT

**Visual Output for Layered Topologies in Power System Analysis**  
A library to visualize power flow-based results arranged in MATPOWER cases.

[![MATLAB](https://img.shields.io/badge/MATLAB-Code-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Paper Status](https://img.shields.io/badge/Paper-Under%20Peer%20Review-yellow.svg)](#scientific-paper)
[![Guide](https://img.shields.io/badge/Guide-PDF-blue.svg)](VOLT_user_guide.pdf)
[![Examples](https://img.shields.io/badge/Examples-Script-brightgreen.svg)](EXAMPLES.m)

## 🖼️ Preview

<p align="center">
  <a href="figures/case5_bus_max_details.pdf">
    <img src="figures/case5_bus_max_details.png" alt="VOLT Preview" width="650">
  </a>
  <br>
  <em>Example of network visualization generated with VOLT. Click the image to open the high-resolution vector PDF.</em>
</p>

## 📁 Repository Structure

```text
.
├── figures/             # Preview images (.png) and vector plots (.pdf)
├── EXAMPLES.m           # Demonstration script organized in executable sections
├── LICENSE              # License terms
├── README.md            # Repository documentation
├── VOLT.m               # Core algorithm and functions
└── VOLT_user_guide.pdf  # Comprehensive user manual

```

## 🌟 Key Features & Core Contributions

* **Dynamic Flow Rendering**: Automatic orientation of branch arrows according to physical active power flow direction ($P$) and dynamic colormap rescaling.
* **Layered Architecture**: Independent layer separation for bus metrics, branch metrics, and graphic legends to prevent visual clutter and overlapping.
* **Publication-Ready Outputs**: Generation of customizable MATLAB figures (`.fig`) and vector formats (`.pdf`, `.eps`) ready for academic papers and teaching.
* **Layout Flexibility**: Support for both automatic placement (force-directed graph algorithms) and custom spatial coordinates.

## 📋 System Requirements

* **MATLAB**: Version R2023b or later with standard **Graph Theory Toolbox** functions.
* **[MATPOWER](https://matpower.org/)**: Free, open-source tools for electric power system simulation and optimization (required for data structure handling and the `ext2int` function).
                                         Version 7.0 or later (earlier versions have not been tested).
* **Recommended Hardware**: A dedicated graphics card (GPU) to ensure smooth rendering performance on medium to large power networks (up to 2,500 buses).

## ⚙️ Installation & Setup

VOLT is distributed as a single lightweight file (`VOLT.m`) and requires no complex installation procedure or external compilation.

### Method 1: Working Directory (Quick Setup)
Copy the `VOLT.m` file directly into the working folder where your main MATLAB script resides.

### Method 2: Adding to MATLAB Global Path (Recommended)
To invoke VOLT from any project directory without duplicating the file:

**Via MATLAB Command Window:**
```matlab
addpath('C:/Path/To/Your/VOLT_Folder');
savepath; % Saves the path for future MATLAB sessions
```

📝 How to Cite

If VOLT made your power system visualizations easier or supported your academic work, we would truly appreciate a citation:

```text
@misc{VOLT2026,
  author       = {De Caro, Fabrizio and Vaccaro, Alfredo},
  title        = {{VOLT}: Visual Output for Layered Topologies (Version 1.0)},
  year         = {2026},
  howpublished = {MATLAB Toolbox, University of Sannio},
  note         = {Available at GitHub repository},
  url          = {[https://github.com/FaberDC/VOLT](https://github.com/username/VOLT)}
}
```

## 📜 License

Distributed under the **GNU General Public License v3.0 (GPLv3)**.

Copyright (c) 2026 **[Fabrizio De Caro](https://sites.google.com/view/fdecaro/home-page), Alfredo Vaccaro**  
*Power Systems Research Group — Department of Engineering, University of Sannio, Benevento, Italy*.
