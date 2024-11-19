//
//  Orb.swift
//  CyberLife
//
//  Created by 赵翔宇 on 2024/11/16.
//
import Orb
import Foundation
struct ORB {
    // Mystic
    let mysticOrb = OrbConfiguration(
        backgroundColors: [.purple, .blue, .indigo],
        glowColor: .purple,
        coreGlowIntensity: 1.2
    )

    // Nature
    let natureOrb = OrbConfiguration(
        backgroundColors: [.green, .mint, .teal],
        glowColor: .green,
        speed: 45
    )

    // Sunset
    let sunsetOrb = OrbConfiguration(
        backgroundColors: [.orange, .red, .pink],
        glowColor: .orange,
        coreGlowIntensity: 0.8
    )

    // Ocean
    let oceanOrb = OrbConfiguration(
        backgroundColors: [.blue, .cyan, .teal],
        glowColor: .cyan,
        speed: 75
    )

    // Minimal
    let minimalOrb = OrbConfiguration(
        backgroundColors: [.gray, .white],
        glowColor: .white,
        showWavyBlobs: false,
        showParticles: false,
        speed: 30
    )

    // Cosmic
    let cosmicOrb = OrbConfiguration(
        backgroundColors: [.purple, .pink, .blue],
        glowColor: .white,
        coreGlowIntensity: 1.5,
        speed: 90
    )

    // Fire
    let fireOrb = OrbConfiguration(
        backgroundColors: [.red, .orange, .yellow],
        glowColor: .orange,
        coreGlowIntensity: 1.3,
        speed: 80
    )

    // Arctic
    let arcticOrb = OrbConfiguration(
        backgroundColors: [.cyan, .white, .blue],
        glowColor: .white,
        coreGlowIntensity: 0.75,
        showParticles: true,
        speed: 40
    )

    // Shadow
    let shadowOrb = OrbConfiguration(
        backgroundColors: [.black, .gray],
        glowColor: .gray,
        coreGlowIntensity: 0.7,
        showParticles: false
    )

}
