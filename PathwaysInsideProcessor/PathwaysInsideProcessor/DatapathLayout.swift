// DatapathLayout.swift
// PathwaysInsideProcessor
//
// MIPS single-cycle datapath — exact coordinates from ProcessorDatapathDiagram.svg
// SVG canvas: 1317 × 737.  All x/y values are native SVG units.
// The puzzle view scales everything by (screenW / 1317, screenH / 737).

import CoreGraphics
import SwiftUI

// MARK: - Native canvas dimensions (from SVG viewBox)

// Matches the SVG viewBox exactly so every x/y coordinate taken from the file
// can be used as-is without any manual conversion step.
let svgNativeWidth:  CGFloat = 1317
let svgNativeHeight: CGFloat = 737

// Legacy aliases so older callers compile
let canvasNativeWidth  = svgNativeWidth
let canvasNativeHeight = svgNativeHeight

// MARK: - Component colors (exact draw.io hex values)

struct DatapathColors {
    static let fillYellow  = Color(red: 1.000, green: 0.949, blue: 0.800) // #fff2cc
    static let fillGreen   = Color(red: 0.835, green: 0.910, blue: 0.831) // #d5e8d4
    static let fillRed     = Color(red: 0.973, green: 0.808, blue: 0.800) // #f8cecc
    static let fillPurple  = Color(red: 0.882, green: 0.835, blue: 0.906) // #e1d5e7

    static let strokeYellow = Color(red: 0.839, green: 0.714, blue: 0.337) // #d6b656
    static let strokeGreen  = Color(red: 0.510, green: 0.702, blue: 0.400) // #82b366
    static let strokeRed    = Color(red: 0.722, green: 0.329, blue: 0.314) // #b85450
    static let strokePurple = Color(red: 0.588, green: 0.451, blue: 0.651) // #9673a6
}

// MARK: - Component

enum ComponentColor { case yellow, green, red, purple }

struct MIPSComponent: Identifiable {
    let id:    String
    let label: String
    let svgX:  CGFloat   // SVG rect top-left x
    let svgY:  CGFloat   // SVG rect top-left y
    let w:     CGFloat
    let h:     CGFloat
    let color: ComponentColor

    // Derived geometry — computed from the raw SVG values so call sites
    // don't need to re-derive center/edge positions themselves.
    var cx: CGFloat { svgX + w / 2 }
    var cy: CGFloat { svgY + h / 2 }
    var left:   CGFloat { svgX }
    var right:  CGFloat { svgX + w }
    var top:    CGFloat { svgY }
    var bottom: CGFloat { svgY + h }

    func fill(_ c: ComponentColor) -> Color {
        switch c {
        case .yellow: return DatapathColors.fillYellow
        case .green:  return DatapathColors.fillGreen
        case .red:    return DatapathColors.fillRed
        case .purple: return DatapathColors.fillPurple
        }
    }
    func stroke(_ c: ComponentColor) -> Color {
        switch c {
        case .yellow: return DatapathColors.strokeYellow
        case .green:  return DatapathColors.strokeGreen
        case .red:    return DatapathColors.strokeRed
        case .purple: return DatapathColors.strokePurple
        }
    }
    var fillColor:   Color { fill(color) }
    var strokeColor: Color { stroke(color) }
}

// MARK: - Port

struct MIPSPort: Identifiable {
    let id:       String
    let compId:   String
    let px:       CGFloat   // absolute SVG x of wire endpoint
    let py:       CGFloat   // absolute SVG y of wire endpoint
    let isOutput: Bool
    let label:    String
}

// MARK: - Wire

struct MIPSWire: Identifiable {
    let id:        String
    let from:      String   // port id
    let to:        String   // port id
    let pts:       [CGPoint]
    // Control wires (RegWrite, ALUSrc, Branch, etc.) are pre-drawn in grey/orange
    // and are never puzzle targets — the student only wires data paths.
    var isControl: Bool = false
}

// MARK: - All Components  (svgX, svgY = top-left of SVG rect; w, h = dimensions)

let allComponents: [MIPSComponent] = [
    // id               label                          svgX   svgY    w     h    color
    MIPSComponent(id: "pc",           label: "PC",    svgX:   28, svgY: 468, w:  40, h:  40, color: .green),
    MIPSComponent(id: "instr_mem",    label: "Instruction\nMemory",
                                                       svgX:  108, svgY: 388, w: 160, h: 160, color: .yellow),
    MIPSComponent(id: "pc_adder",     label: "Add\n+4",
                                                       svgX:  188, svgY: 108, w:  80, h: 120, color: .green),
    MIPSComponent(id: "control",      label: "Control\nUnit",
                                                       svgX:  348, svgY: 188, w: 160, h: 120, color: .red),
    MIPSComponent(id: "wr_mux",       label: "Mux",   svgX:  348, svgY: 468, w:  80, h:  80, color: .purple),
    MIPSComponent(id: "registers",    label: "Register\nFile",
                                                       svgX:  468, svgY: 388, w: 160, h: 160, color: .yellow),
    MIPSComponent(id: "sign_extend",  label: "Sign\nExtend",
                                                       svgX:  508, svgY: 668, w: 120, h:  40, color: .green),
    MIPSComponent(id: "shift_left2",  label: "Shift\nLeft 2",
                                                       svgX:  668, svgY: 188, w: 120, h:  40, color: .green),
    MIPSComponent(id: "alu_control",  label: "ALU\nControl",
                                                       svgX:  668, svgY: 628, w: 120, h:  40, color: .red),
    MIPSComponent(id: "alu_mux",      label: "Mux",   svgX:  668, svgY: 468, w:  80, h:  80, color: .purple),
    MIPSComponent(id: "alu",          label: "ALU",   svgX:  788, svgY: 388, w: 120, h: 120, color: .green),
    MIPSComponent(id: "branch_adder", label: "Add",   svgX:  948, svgY: 108, w:  80, h: 120, color: .green),
    MIPSComponent(id: "data_memory",  label: "Data\nMemory",
                                                       svgX:  988, svgY: 388, w: 160, h: 160, color: .yellow),
    MIPSComponent(id: "and_gate",     label: "AND",   svgX: 1108, svgY: 148, w:  80, h: 120, color: .green),
    MIPSComponent(id: "wb_mux",       label: "Mux",   svgX: 1188, svgY: 428, w:  80, h:  80, color: .purple),
    MIPSComponent(id: "branch_mux",   label: "Mux",   svgX: 1148, svgY:  28, w:  80, h:  80, color: .purple),
]

// MARK: - All Ports  (px, py = exact SVG wire-endpoint coordinate)

let allPorts: [MIPSPort] = [

    // PC
    MIPSPort(id: "pc.out", compId: "pc", px:  68, py: 488, isOutput: true,  label: ""),
    MIPSPort(id: "pc.in",  compId: "pc", px:  20, py: 488, isOutput: false, label: ""),

    // Instruction Memory
    MIPSPort(id: "instr_mem.addr", compId: "instr_mem", px:  99, py: 488, isOutput: false, label: "A"),
    MIPSPort(id: "instr_mem.out",  compId: "instr_mem", px: 269, py: 488, isOutput: true,  label: "Instr"),

    // PC+4 Adder
    MIPSPort(id: "pc_adder.in_pc", compId: "pc_adder", px: 180, py: 128, isOutput: false, label: ""),
    MIPSPort(id: "pc_adder.out",   compId: "pc_adder", px: 268, py: 168, isOutput: true,  label: ""),

    // Control Unit
    MIPSPort(id: "control.in",            compId: "control", px: 340, py: 248, isOutput: false, label: "Op"),
    MIPSPort(id: "control.out_aluop",     compId: "control", px: 348, py: 208, isOutput: true,  label: "ALUOp"),
    MIPSPort(id: "control.out_regdst",    compId: "control", px: 368, py: 308, isOutput: true,  label: "RegDst"),
    MIPSPort(id: "control.out_regwrite",  compId: "control", px: 408, py: 308, isOutput: true,  label: "RegWr"),
    MIPSPort(id: "control.out_branch",    compId: "control", px: 448, py: 188, isOutput: true,  label: "Branch"),
    MIPSPort(id: "control.out_alusrc",    compId: "control", px: 448, py: 308, isOutput: true,  label: "ALUSrc"),
    MIPSPort(id: "control.out_memwrite",  compId: "control", px: 488, py: 308, isOutput: true,  label: "MemWr"),
    MIPSPort(id: "control.out_memread",   compId: "control", px: 508, py: 248, isOutput: true,  label: "MemRd"),
    MIPSPort(id: "control.out_memtoreg",  compId: "control", px: 508, py: 208, isOutput: true,  label: "Mem2Reg"),

    // RegDst MUX
    MIPSPort(id: "wr_mux.in0", compId: "wr_mux", px: 340, py: 488, isOutput: false, label: "rt"),
    MIPSPort(id: "wr_mux.in1", compId: "wr_mux", px: 340, py: 528, isOutput: false, label: "rd"),
    MIPSPort(id: "wr_mux.out", compId: "wr_mux", px: 428, py: 488, isOutput: true,  label: ""),

    // Register File
    MIPSPort(id: "registers.rr1", compId: "registers", px: 459, py: 408, isOutput: false, label: "RR1"),
    MIPSPort(id: "registers.rr2", compId: "registers", px: 460, py: 448, isOutput: false, label: "RR2"),
    MIPSPort(id: "registers.wr",  compId: "registers", px: 460, py: 488, isOutput: false, label: "WR"),
    MIPSPort(id: "registers.wd",  compId: "registers", px: 460, py: 528, isOutput: false, label: "WD"),
    MIPSPort(id: "registers.rd1", compId: "registers", px: 628, py: 408, isOutput: true,  label: "RD1"),
    MIPSPort(id: "registers.rd2", compId: "registers", px: 628, py: 488, isOutput: true,  label: "RD2"),

    // Sign Extend
    MIPSPort(id: "sign_extend.in",  compId: "sign_extend", px: 500, py: 688, isOutput: false, label: "16"),
    MIPSPort(id: "sign_extend.out", compId: "sign_extend", px: 628, py: 688, isOutput: true,  label: "32"),

    // Shift Left 2
    MIPSPort(id: "shift_left2.in",  compId: "shift_left2", px: 660, py: 208, isOutput: false, label: ""),
    MIPSPort(id: "shift_left2.out", compId: "shift_left2", px: 788, py: 208, isOutput: true,  label: ""),

    // ALU Control
    MIPSPort(id: "alu_control.in",  compId: "alu_control", px: 660, py: 648, isOutput: false, label: ""),
    MIPSPort(id: "alu_control.out", compId: "alu_control", px: 728, py: 628, isOutput: true,  label: ""),

    // ALUSrc MUX
    MIPSPort(id: "alu_mux.in0", compId: "alu_mux", px: 660, py: 488, isOutput: false, label: "0"),
    MIPSPort(id: "alu_mux.in1", compId: "alu_mux", px: 660, py: 528, isOutput: false, label: "1"),
    MIPSPort(id: "alu_mux.out", compId: "alu_mux", px: 748, py: 488, isOutput: true,  label: ""),

    // ALU
    MIPSPort(id: "alu.a",      compId: "alu", px: 780, py: 408, isOutput: false, label: "A"),
    MIPSPort(id: "alu.b",      compId: "alu", px: 782, py: 488, isOutput: false, label: "B"),
    MIPSPort(id: "alu.result", compId: "alu", px: 908, py: 448, isOutput: true,  label: "Res"),
    MIPSPort(id: "alu.zero",   compId: "alu", px: 888, py: 388, isOutput: true,  label: "Zero"),

    // Branch Adder
    MIPSPort(id: "branch_adder.in_a", compId: "branch_adder", px: 940, py: 128, isOutput: false, label: "A"),
    MIPSPort(id: "branch_adder.in_b", compId: "branch_adder", px: 940, py: 208, isOutput: false, label: "B"),
    MIPSPort(id: "branch_adder.out",  compId: "branch_adder", px: 1028, py: 168, isOutput: true,  label: ""),

    // Data Memory
    MIPSPort(id: "data_memory.addr",  compId: "data_memory", px:  980, py: 408, isOutput: false, label: "Addr"),
    MIPSPort(id: "data_memory.wdata", compId: "data_memory", px:  980, py: 528, isOutput: false, label: "WD"),
    MIPSPort(id: "data_memory.rdata", compId: "data_memory", px: 1149, py: 448, isOutput: true,  label: "RD"),

    // AND gate
    MIPSPort(id: "and_gate.in_zero",   compId: "and_gate", px: 1100, py: 248, isOutput: false, label: "Z"),
    MIPSPort(id: "and_gate.in_branch", compId: "and_gate", px: 1100, py: 168, isOutput: false, label: "Br"),
    MIPSPort(id: "and_gate.out",       compId: "and_gate", px: 1188, py: 208, isOutput: true,  label: ""),

    // WB MUX (MemToReg)
    MIPSPort(id: "wb_mux.in0", compId: "wb_mux", px: 1180, py: 488, isOutput: false, label: "0"),
    MIPSPort(id: "wb_mux.in1", compId: "wb_mux", px: 1180, py: 448, isOutput: false, label: "1"),
    MIPSPort(id: "wb_mux.out", compId: "wb_mux", px: 1268, py: 448, isOutput: true,  label: ""),

    // PCSrc MUX
    MIPSPort(id: "branch_mux.in0",  compId: "branch_mux", px: 1140, py:  48, isOutput: false, label: "0"),
    MIPSPort(id: "branch_mux.in1",  compId: "branch_mux", px: 1140, py:  88, isOutput: false, label: "1"),
    MIPSPort(id: "branch_mux.ctrl", compId: "branch_mux", px: 1168, py: 116, isOutput: false, label: ""),
    MIPSPort(id: "branch_mux.out",  compId: "branch_mux", px: 1228, py:  48, isOutput: true,  label: ""),
]

// MARK: - Fast lookups

// Pre-built at launch so drag-gesture hot paths get O(1) port/component access
// instead of O(n) linear searches through allPorts / allComponents.
let portById: [String: MIPSPort] = Dictionary(uniqueKeysWithValues: allPorts.map { ($0.id, $0) })
let compById: [String: MIPSComponent] = Dictionary(uniqueKeysWithValues: allComponents.map { ($0.id, $0) })

// MARK: - All Wires  (pts match exact SVG path data)

let allWires: [MIPSWire] = [

    // ── DATA WIRES ─────────────────────────────────────────────────────────

    // PC → Instruction Memory
    MIPSWire(id: "w_pc_instrMem",
             from: "pc.out", to: "instr_mem.addr",
             pts: [.p(68,488), .p(99,488)]),

    // PC → PC+4 Adder
    MIPSWire(id: "w_pc_pcAdder",
             from: "pc.out", to: "pc_adder.in_pc",
             pts: [.p(68,488), .p(88,488), .p(88,128), .p(180,128)]),

    // PC+4 Adder → Branch Adder input A
    MIPSWire(id: "w_pcAdder_branchAdder",
             from: "pc_adder.out", to: "branch_adder.in_a",
             pts: [.p(268,168), .p(428,168), .p(428,128), .p(940,128)]),

    // PC+4 Adder → PCSrc MUX input 0
    MIPSWire(id: "w_pcAdder_branchMux",
             from: "pc_adder.out", to: "branch_mux.in0",
             pts: [.p(268,168), .p(368,168), .p(368,48), .p(1140,48)]),

    // PCSrc MUX → PC (feedback wraps around top)
    MIPSWire(id: "w_branchMux_pc",
             from: "branch_mux.out", to: "pc.in",
             pts: [.p(1228,48), .p(1228,88), .p(1248,88), .p(1248,8),
                   .p(8,8), .p(8,488), .p(20,488)]),

    // Instruction Memory → RegFile RR1
    MIPSWire(id: "w_instr_rr1",
             from: "instr_mem.out", to: "registers.rr1",
             pts: [.p(269,488), .p(308,488), .p(308,408), .p(459,408)]),

    // Instruction Memory → RegFile RR2
    MIPSWire(id: "w_instr_rr2",
             from: "instr_mem.out", to: "registers.rr2",
             pts: [.p(269,488), .p(308,488), .p(308,448), .p(460,448)]),

    // Instruction Memory → RegDst MUX input 0 (rt field)
    MIPSWire(id: "w_instr_wrMux0",
             from: "instr_mem.out", to: "wr_mux.in0",
             pts: [.p(269,488), .p(308,488), .p(308,448), .p(328,448),
                   .p(328,488), .p(340,488)]),

    // Instruction Memory → RegDst MUX input 1 (rd field)
    MIPSWire(id: "w_instr_wrMux1",
             from: "instr_mem.out", to: "wr_mux.in1",
             pts: [.p(269,488), .p(308,488), .p(308,528), .p(340,528)]),

    // Instruction Memory → Sign Extend
    MIPSWire(id: "w_instr_signExtend",
             from: "instr_mem.out", to: "sign_extend.in",
             pts: [.p(269,488), .p(308,488), .p(308,688), .p(500,688)]),

    // RegDst MUX → RegFile Write Register
    MIPSWire(id: "w_wrMux_regWr",
             from: "wr_mux.out", to: "registers.wr",
             pts: [.p(428,488), .p(460,488)]),

    // RegFile RD1 → ALU input A
    MIPSWire(id: "w_rd1_aluA",
             from: "registers.rd1", to: "alu.a",
             pts: [.p(628,408), .p(780,408)]),

    // RegFile RD2 → ALUSrc MUX input 0
    MIPSWire(id: "w_rd2_aluMux",
             from: "registers.rd2", to: "alu_mux.in0",
             pts: [.p(628,488), .p(660,488)]),

    // RegFile RD2 → Data Memory write data (store)
    MIPSWire(id: "w_rd2_dataMem",
             from: "registers.rd2", to: "data_memory.wdata",
             pts: [.p(628,488), .p(648,488), .p(648,568), .p(908,568),
                   .p(908,528), .p(980,528)]),

    // Sign Extend → ALUSrc MUX input 1
    MIPSWire(id: "w_signExtend_aluMux",
             from: "sign_extend.out", to: "alu_mux.in1",
             pts: [.p(628,688), .p(648,688), .p(648,528), .p(660,528)]),

    // Sign Extend → Shift Left 2 (branch offset)
    MIPSWire(id: "w_signExtend_shiftLeft2",
             from: "sign_extend.out", to: "shift_left2.in",
             pts: [.p(628,688), .p(648,688), .p(648,208), .p(660,208)]),

    // Shift Left 2 → Branch Adder input B
    MIPSWire(id: "w_shiftLeft2_branchAdder",
             from: "shift_left2.out", to: "branch_adder.in_b",
             pts: [.p(788,208), .p(940,208)]),

    // ALUSrc MUX → ALU input B
    MIPSWire(id: "w_aluMux_aluB",
             from: "alu_mux.out", to: "alu.b",
             pts: [.p(748,488), .p(782,488)]),

    // ALU result → Data Memory address
    MIPSWire(id: "w_aluResult_dataMem",
             from: "alu.result", to: "data_memory.addr",
             pts: [.p(908,448), .p(948,448), .p(948,408), .p(980,408)]),

    // ALU result → WB MUX input 0 (ALU path)
    MIPSWire(id: "w_aluResult_wbMux",
             from: "alu.result", to: "wb_mux.in0",
             pts: [.p(908,448), .p(948,448), .p(948,608),
                   .p(1168,608), .p(1168,488), .p(1180,488)]),

    // ALU Zero flag → AND gate
    MIPSWire(id: "w_aluZero_andGate",
             from: "alu.zero", to: "and_gate.in_zero",
             pts: [.p(888,388), .p(888,268), .p(1088,268),
                   .p(1088,248), .p(1100,248)]),

    // Branch Adder → PCSrc MUX input 1
    MIPSWire(id: "w_branchAdder_branchMux",
             from: "branch_adder.out", to: "branch_mux.in1",
             pts: [.p(1028,168), .p(1048,168), .p(1048,88), .p(1140,88)]),

    // Data Memory read data → WB MUX input 1
    MIPSWire(id: "w_dataMem_wbMux",
             from: "data_memory.rdata", to: "wb_mux.in1",
             pts: [.p(1149,448), .p(1180,448)]),

    // WB MUX → RegFile Write Data (wraps bottom)
    MIPSWire(id: "w_wbMux_regWD",
             from: "wb_mux.out", to: "registers.wd",
             pts: [.p(1268,448), .p(1308,448), .p(1308,728),
                   .p(448,728), .p(448,528), .p(460,528)]),

    // ── CONTROL WIRES (isControl: true — pre-drawn, not puzzle targets) ────

    // InstrMem → Control Unit (opcode/function bits)
    MIPSWire(id: "w_instr_control",
             from: "instr_mem.out", to: "control.in",
             pts: [.p(269,488), .p(308,488), .p(308,248), .p(340,248)],
             isControl: true),

    // Control → ALU Control (ALUOp)
    MIPSWire(id: "w_ctrl_aluControl",
             from: "control.out_aluop", to: "alu_control.in",
             pts: [.p(348,208), .p(288,208), .p(288,648), .p(660,648)],
             isControl: true),

    // ALU Control → ALU
    MIPSWire(id: "w_aluControl_alu",
             from: "alu_control.out", to: "alu.b",
             pts: [.p(728,628), .p(728,558)],
             isControl: true),

    // Control → RegDst MUX (RegDst)
    MIPSWire(id: "w_ctrl_regDst",
             from: "control.out_regdst", to: "wr_mux.in0",
             pts: [.p(368,308), .p(368,460)],
             isControl: true),

    // Control → ALUSrc MUX (ALUSrc)
    MIPSWire(id: "w_ctrl_aluSrc",
             from: "control.out_alusrc", to: "alu_mux.in0",
             pts: [.p(448,308), .p(448,348), .p(688,348), .p(688,460)],
             isControl: true),

    // Control → WB MUX (MemToReg)
    MIPSWire(id: "w_ctrl_memToReg",
             from: "control.out_memtoreg", to: "wb_mux.in0",
             pts: [.p(508,208), .p(608,208), .p(608,308),
                   .p(1208,308), .p(1208,420)],
             isControl: true),

    // Control → Data Memory (MemRead)
    MIPSWire(id: "w_ctrl_memRead",
             from: "control.out_memread", to: "data_memory.addr",
             pts: [.p(508,248), .p(548,248), .p(548,288),
                   .p(1288,288), .p(1288,568), .p(1068,568), .p(1068,556)],
             isControl: true),

    // Control → Data Memory (MemWrite)
    MIPSWire(id: "w_ctrl_memWrite",
             from: "control.out_memwrite", to: "data_memory.addr",
             pts: [.p(488,308), .p(488,328), .p(1068,328), .p(1068,380)],
             isControl: true),

    // Control → AND gate (Branch)
    MIPSWire(id: "w_ctrl_branch",
             from: "control.out_branch", to: "and_gate.in_branch",
             pts: [.p(448,188), .p(448,168), .p(908,168),
                   .p(908,248), .p(1068,248), .p(1068,168), .p(1100,168)],
             isControl: true),

    // Control → RegFile (RegWrite)
    MIPSWire(id: "w_ctrl_regWrite",
             from: "control.out_regwrite", to: "registers.wr",
             pts: [.p(408,308), .p(408,368), .p(548,368), .p(548,380)],
             isControl: true),

    // AND gate → PCSrc MUX control
    MIPSWire(id: "w_andGate_branchMuxCtrl",
             from: "and_gate.out", to: "branch_mux.ctrl",
             pts: [.p(1188,208), .p(1208,208), .p(1208,128),
                   .p(1168,128), .p(1168,116)],
             isControl: true),
]

// MARK: - Wire lookup

let wireById: [String: MIPSWire] = Dictionary(uniqueKeysWithValues: allWires.map { ($0.id, $0) })

// MARK: - Active Wire Sets (per instruction type — data wires only)

// Defines WHICH data wires are "live" for each instruction. Used in two places:
//  1. Canvas rendering — live wires' ports are shown as draggable dots.
//  2. Scoring — the puzzle is correct only when the user has drawn exactly this set.
// Control wires are always drawn and never appear here.
let activeWireIds: [String: Set<String>] = [

    // R-Type: add / sub / and / or / slt
    "rtype": [
        "w_pc_instrMem",
        "w_pc_pcAdder",
        "w_pcAdder_branchMux",
        "w_branchMux_pc",
        "w_instr_rr1",
        "w_instr_rr2",
        "w_instr_wrMux1",        // rd field (RegDst=1)
        "w_wrMux_regWr",
        "w_rd1_aluA",
        "w_rd2_aluMux",          // RD2 → ALU Mux (ALUSrc=0)
        "w_aluMux_aluB",
        "w_aluResult_wbMux",
        "w_wbMux_regWD",
    ],

    // Load Word: lw rt, offset(rs)
    "load": [
        "w_pc_instrMem",
        "w_pc_pcAdder",
        "w_pcAdder_branchMux",
        "w_branchMux_pc",
        "w_instr_rr1",
        "w_instr_rr2",
        "w_instr_wrMux0",        // rt field (RegDst=0)
        "w_wrMux_regWr",
        "w_instr_signExtend",
        "w_signExtend_aluMux",   // sign-ext → ALUSrc input 1
        "w_rd1_aluA",
        "w_aluMux_aluB",
        "w_aluResult_dataMem",
        "w_dataMem_wbMux",
        "w_wbMux_regWD",
    ],

    // Store Word: sw rt, offset(rs)
    "store": [
        "w_pc_instrMem",
        "w_pc_pcAdder",
        "w_pcAdder_branchMux",
        "w_branchMux_pc",
        "w_instr_rr1",
        "w_instr_rr2",
        "w_instr_signExtend",
        "w_signExtend_aluMux",
        "w_rd1_aluA",
        "w_rd2_dataMem",
        "w_aluMux_aluB",
        "w_aluResult_dataMem",
    ],

    // Branch Equal: beq rs, rt, label
    "branch": [
        "w_pc_instrMem",
        "w_pc_pcAdder",
        "w_pcAdder_branchAdder",
        "w_pcAdder_branchMux",
        "w_branchMux_pc",
        "w_instr_rr1",
        "w_instr_rr2",
        "w_instr_signExtend",
        "w_signExtend_shiftLeft2",
        "w_shiftLeft2_branchAdder",
        "w_branchAdder_branchMux",
        "w_rd1_aluA",
        "w_rd2_aluMux",
        "w_aluMux_aluB",
        "w_aluZero_andGate",
    ],
]

// MARK: - CGPoint convenience

extension CGPoint {
    static func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
}

// MARK: - Scale helpers

// Converts a single SVG-space point to screen space for a given canvas size.
func scalePoint(_ pt: CGPoint, to size: CGSize) -> CGPoint {
    CGPoint(x: pt.x * size.width  / svgNativeWidth,
            y: pt.y * size.height / svgNativeHeight)
}

// Builds a SwiftUI Path from a wire's SVG waypoints, scaled to the canvas size.
func wirePath(for wire: MIPSWire, scaledTo size: CGSize) -> Path {
    guard wire.pts.count >= 2 else { return Path() }
    return Path { p in
        p.move(to: scalePoint(wire.pts[0], to: size))
        for pt in wire.pts.dropFirst() { p.addLine(to: scalePoint(pt, to: size)) }
    }
}

// Returns a screen-space position map for every port — used when rendering
// port dots and computing snap distances during drag gestures.
func buildFullPortPositions(canvasSize: CGSize) -> [String: CGPoint] {
    var map: [String: CGPoint] = [:]
    for port in allPorts {
        map[port.id] = CGPoint(
            x: port.px * canvasSize.width  / svgNativeWidth,
            y: port.py * canvasSize.height / svgNativeHeight)
    }
    return map
}

// MARK: - Puzzle helpers

// Splits the active wire endpoints into output (drag source) and input (drop target)
// sets so the canvas can render them with distinct visuals.
func getActivePorts(instrType: String) -> (outputs: Set<String>, inputs: Set<String>) {
    guard let ids = activeWireIds[instrType] else { return ([], []) }
    var out = Set<String>(); var inp = Set<String>()
    for wid in ids {
        if let w = wireById[wid] { out.insert(w.from); inp.insert(w.to) }
    }
    return (out, inp)
}

// Returns the component IDs touched by any active wire — used to visually
// emphasise the relevant datapath components for a given instruction type.
func activeComponentIds(instrType: String) -> Set<String> {
    guard let ids = activeWireIds[instrType] else { return [] }
    var comps = Set<String>()
    for wid in ids {
        if let w = wireById[wid] {
            if let fp = portById[w.from] { comps.insert(fp.compId) }
            if let tp = portById[w.to]   { comps.insert(tp.compId) }
        }
    }
    return comps
}

// Derives the canonical answer set from the wire definitions, not from a
// separate hardcoded table, so the two sources of truth can never diverge.
func correctConnections(for instrType: String) -> Set<Connection> {
    guard let ids = activeWireIds[instrType] else { return [] }
    return Set(ids.compactMap { wid -> Connection? in
        guard let w  = wireById[wid],
              let fp = portById[w.from],
              let tp = portById[w.to] else { return nil }
        return Connection(fromComponent: fp.compId, fromPort: w.from,
                          toComponent:   tp.compId, toPort:   w.to)
    })
}

// MARK: - Legacy stubs (keep compiler happy if anything still imports these names)

struct ComponentLayoutInfo { let id, label: String; let centerX, centerY, widthFrac, heightFrac: CGFloat }
struct PortLayoutInfo       { let id, label: String; let isOutput: Bool; let relativeY: CGFloat }
let puzzleComponentLayouts: [String: [String: ComponentLayoutInfo]] = [:]
let portLayoutDefs:         [String: [PortLayoutInfo]]              = [:]
func portCanvasPos(portId: String, componentId: String, puzzleId: String, canvasSize: CGSize) -> CGPoint? { nil }
func buildPortPositions(puzzle: Puzzle, canvasSize: CGSize) -> [String: CGPoint] { [:] }
func buildPortToComponentMap(puzzle: Puzzle) -> [String: String] { [:] }
func buildOutputPortIds(puzzle: Puzzle) -> Set<String> { [] }
func buildInputPortIds(puzzle: Puzzle)  -> Set<String> { [] }
