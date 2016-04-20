// $Id: $
// File name:   tb_edgedetect.sv
// Created:     4/20/2016
// Author:      Vikram Manja
// Lab Section: 337-05
// Version:     1.0  Initial Design Entry
// Description: This is the testbench for detection of edges... edgedetect
`timescale 1ns / 100ps

module tb_intensity();
// Define parameters
parameter CLK_PERIOD	= 2; //50 MHZ