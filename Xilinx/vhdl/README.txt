10/16/2017 Build 7
  Provide Rx/Tx on external pads to work around QNX's inability to
  reset the baud rate to 115200
    # uart_rx, E18 PIO.38 U4
    # uart_tx, E19 PIO.37 V4
2/22/2017 Build 6
  Build 6 was used during the New Zealand to Punta Arenas mission.
  Supported:
    2 Counter channels for 2 PMTs
    2 Heater/Controller channels with Analog out/in and status
    Temp Sensor support
    115200 Baud connection via USB