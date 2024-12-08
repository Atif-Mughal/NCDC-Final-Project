<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AXI4 Verification IP</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      line-height: 1.6;
      margin: 0;
      padding: 0 20px;
      background-color: #f9f9f9;
      color: #333;
    }
    h1, h2 {
      color: #0056b3;
    }
    pre {
      background-color: #eee;
      padding: 10px;
      border-left: 5px solid #ccc;
      overflow-x: auto;
    }
    code {
      background-color: #eee;
      padding: 2px 4px;
      border-radius: 3px;
    }
    ul {
      margin: 10px 0;
      padding-left: 20px;
    }
    li {
      margin-bottom: 5px;
    }
    .container {
      max-width: 900px;
      margin: auto;
      background: #fff;
      padding: 20px;
      box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
    }
    .footer {
      margin-top: 20px;
      text-align: center;
      font-size: 0.9em;
      color: #555;
    }
  </style>
</head>
<body>
  <div class="container">
    <h1>AXI4 Verification IP (VIP)</h1>
    <h2>Overview</h2>
    <p>The <strong>AXI4 Verification IP (VIP)</strong> is a reusable, configurable UVM-based testbench for verifying AXI4-compliant designs. This VIP supports both <strong>AXI4 Full</strong> and <strong>AXI4 Lite</strong> protocols and includes components for verifying the behavior of <strong>AXI Masters</strong> and <strong>AXI Slaves</strong>.</p>
    <p>The VIP ensures compliance with the AXI4 protocol, providing a robust environment for simulation, random testing, and directed testing.</p>
    
    <h2>Features</h2>
    <ul>
      <li>Supports AXI4 Full and Lite protocols.</li>
      <li>Implements UVM-compliant Master and Slave UVCs.</li>
      <li>Fully parameterized for:
        <ul>
          <li>Address width</li>
          <li>Data width</li>
          <li>ID width</li>
        </ul>
      </li>
      <li>Includes:
        <ul>
          <li>Configurable AXI Master Sequencer, Driver, and Monitor.</li>
          <li>Configurable AXI Slave Sequencer, Driver, and Monitor.</li>
          <li>AXI4-compliant Master-Slave Interfaces.</li>
        </ul>
      </li>
      <li>Provides:
        <ul>
          <li>Randomized transaction generation.</li>
          <li>Protocol checks and coverage metrics.</li>
          <li>Support for both burst and single-beat transactions.</li>
        </ul>
      </li>
    </ul>

    <h2>Getting Started</h2>
    <h3>Prerequisites</h3>
    <ul>
      <li>SystemVerilog simulator (e.g., Synopsys VCS, Cadence Xcelium, Mentor QuestaSim).</li>
      <li>UVM library (Unified Verification Methodology).</li>
    </ul>

    <h3>Directory Structure</h3>
    <pre>
axi4_vip/
├── README.html
├── src/
│   ├── axi4_if.sv            # AXI4 interface
│   ├── axi_master_uvc.sv     # Master UVC components
│   ├── axi_slave_uvc.sv      # Slave UVC components
│   ├── axi_master_seq_item.sv # Master sequence item
│   ├── axi_slave_seq_item.sv # Slave sequence item
│   ├── axi_master_sequencer.sv # Master sequencer
│   ├── axi_slave_sequencer.sv # Slave sequencer
│   ├── axi_driver.sv         # Driver for AXI4 transactions
│   ├── axi_monitor.sv        # Monitor for protocol compliance
│   ├── axi_tb.sv             # Top-level testbench
│   ├── axi_dut.sv            # Sample DUT
└── tests/
    ├── example_test.sv       # Example UVM test
    ├── example_sequence.sv   # Example sequence
    </pre>

    <h3>Running the Simulation</h3>
    <ol>
      <li>Clone the repository:
        <pre>
git clone https://github.com/your_username/axi4_vip.git
cd axi4_vip
        </pre>
      </li>
      <li>Compile and run with your simulator:
        <pre>
vcs -full64 -sverilog -ntb_opts uvm src/*.sv tests/*.sv -o simv
./simv
        </pre>
      </li>
      <li>Analyze the results in the log file or waveform viewer.</li>
    </ol>

    <h2>Usage</h2>
    <h3>Configuring the VIP</h3>
    <p>The VIP supports parameterization for address width, data width, and ID width. Edit these parameters in the respective files (<code>axi4_if</code>, <code>axi_master_seq_item</code>, etc.) or pass them as macros during compilation.</p>
    <pre>
// In axi4_if.sv
interface axi4_if #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 64, ID_WIDTH = 4);
    </pre>

    <h3>Writing Custom Tests</h3>
    <ol>
      <li>Create a new UVM test by extending the base test class.</li>
      <li>Define sequences in the sequencer for custom transactions.</li>
      <li>Use monitors to capture transactions and validate DUT behavior.</li>
    </ol>

    <h2>Contributing</h2>
    <p>Contributions are welcome! If you find any bugs or want to enhance this project:</p>
    <ol>
      <li>Fork the repository.</li>
      <li>Create a new branch for your feature or bugfix.</li>
      <li>Commit your changes and push them to your fork.</li>
      <li>Open a pull request.</li>
    </ol>

    <h2>License</h2>
    <p>This project is licensed under the MIT License. See the <code>LICENSE</code> file for details.</p>

    <div class="footer">
      <p>Special thanks to contributors and the open-source community for supporting UVM-based verification development.</p>
    </div>
  </div>
</body>
</html>
