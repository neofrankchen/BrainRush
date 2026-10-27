import SwiftUI

enum CatFraming {
    case fullBody, portrait
}

struct CatLocomotion {
    var facing: CGFloat = 0
    var walkPhase: CGFloat = 0
    var walkAmount: CGFloat = 0
    var curl: CGFloat = 0
}

/// One articulated character, sampled by its owner. Drawing has no side effects.
struct CatRigView: View {
    var mood: CatMood = .content
    var action: CatAction = .none
    var actionProgress: CGFloat = 0
    var gesture: CatGesturePose? = nil
    var motion: CatLocomotion = .init()
    var time: TimeInterval = 0
    var framing: CatFraming = .fullBody
    var reduceMotion = false

    var body: some View {
        Canvas { context, size in
            let side = min(size.width, size.height)
            var drawing = context
            drawing.translateBy(x: (size.width - side) / 2, y: (size.height - side) / 2)
            drawing.scaleBy(x: side / 320, y: side / 320)
            if framing == .portrait {
                // Reframe the very same head and shoulders instead of substituting an avatar.
                let roll = reduceMotion ? 0 : (gesture ?? .sample(action, progress: actionProgress)).roll
                let zoom = 1.35 - 0.35 * roll
                drawing.translateBy(x: -55 * (1 - roll), y: -8 * (1 - roll))
                drawing.scaleBy(x: zoom, y: zoom)
            }
            CatIllustration(mood: mood,
                            gesture: gesture ?? .sample(action, progress: actionProgress),
                            motion: motion, time: time, reduced: reduceMotion)
                .draw(in: drawing)
        }
        .accessibilityHidden(true)
    }
}

private struct CatIllustration {
    let mood: CatMood
    let gesture: CatGesturePose
    let motion: CatLocomotion
    let time: TimeInterval
    let reduced: Bool

    private let outline = Color(red: 0.34, green: 0.22, blue: 0.13)
    private let stripe = Color(red: 0.47, green: 0.35, blue: 0.23)
    private let furLight = Color(red: 0.87, green: 0.74, blue: 0.55)
    private let fur = Color(red: 0.73, green: 0.59, blue: 0.42)
    private let furShade = Color(red: 0.57, green: 0.43, blue: 0.29)
    private let cream = Color(red: 1.0, green: 0.96, blue: 0.83)
    private let creamShade = Color(red: 0.88, green: 0.79, blue: 0.65)
    private let pink = Color(red: 0.94, green: 0.59, blue: 0.48)

    private var t: CGFloat { reduced ? 0 : CGFloat(time) }
    private var curl: CGFloat { unit(motion.curl) }
    private var turn: CGFloat { unit(motion.facing) * (1 - curl) }
    private var side: CGFloat { sin(turn * .pi) }
    private var front: CGFloat { max(0, cos(turn * .pi)) }
    private var back: CGFloat { max(0, -cos(turn * .pi)) }
    private var pet: CGFloat { gesture.pet }
    private var roll: CGFloat { reduced ? 0 : gesture.roll }
    private var cheer: CGFloat { gesture.cheer }
    private var stride: CGFloat { reduced ? 0 : motion.walkAmount * (1 - curl) }
    private var breath: CGFloat { sin(t * (1.65 - 0.35 * curl)) * (1.2 + 2 * curl) }

    func draw(in original: GraphicsContext) {
        var context = original
        if roll > 0 {
            // Lift the rolling torso as its right flank becomes the contact edge.
            context.translateBy(x: 160 - 65 * roll, y: 225 - 43 * roll)
            context.rotate(by: .degrees(Double(roll * 76)))
            context.translateBy(x: -160, y: -225)
        }
        if curl < 0.5 { tail(in: context) }
        hindLeg(in: context, left: true)
        hindLeg(in: context, left: false)
        torso(in: context)
        foreleg(in: context, left: true)
        foreleg(in: context, left: false)
        head(in: context)
        if curl >= 0.5 { tail(in: context) }
    }

    private func torso(in original: GraphicsContext) {
        var c = original
        c.translateBy(x: 158 + side * 7 + curl * 18 - side * stride * 17, y: 281 - stride * 7)
        c.scaleBy(x: 1 + curl * 0.25 + roll * 0.08 + side * stride * 0.25 + breath * curl * 0.003,
                  y: 1 - curl * 0.38 + breath * (0.003 + curl * 0.005) - stride * 0.12)
        let silhouette = path { p in
            p.move(to: pt(-46, -121))
            p.addCurve(to: pt(-64, -66), control1: pt(-58, -105), control2: pt(-51, -87))
            p.addLine(to: pt(-69, -70))
            p.addCurve(to: pt(-74, -28), control1: pt(-68, -54), control2: pt(-83, -43))
            p.addCurve(to: pt(-46, 2), control1: pt(-76, -6), control2: pt(-68, 3))
            p.addCurve(to: pt(48, 1), control1: pt(-17, 6), control2: pt(27, 6))
            p.addCurve(to: pt(74, -32), control1: pt(72, 0), control2: pt(80, -13))
            p.addCurve(to: pt(62, -70), control1: pt(73, -48), control2: pt(66, -55))
            p.addLine(to: pt(67, -68))
            p.addCurve(to: pt(46, -121), control1: pt(54, -91), control2: pt(58, -104))
            p.addCurve(to: pt(-46, -121), control1: pt(22, -136), control2: pt(-24, -136))
            p.closeSubpath()
        }
        paint(silhouette, in: c, colors: [furLight, fur, furShade], from: pt(-52, -128), to: pt(65, 17))
        var detail = c
        detail.clip(to: silhouette)
        // Shoulder and flank markings follow the body, including its breathing deformation.
        for sign: CGFloat in [-1, 1] {
            for i in 0..<3 {
                let y = CGFloat(i) * 26 - 103
                let mark = path { p in
                    p.move(to: pt(sign * 60, y))
                    p.addCurve(to: pt(sign * 27, y + 14), control1: pt(sign * 42, y - 5), control2: pt(sign * 38, y + 8))
                    p.addCurve(to: pt(sign * 70, y + 15), control1: pt(sign * 47, y + 9), control2: pt(sign * 55, y + 21))
                    p.closeSubpath()
                }
                detail.fill(mark, with: .color(stripe.opacity(0.78)))
            }
        }
        if back < 0.99 {
            var chest = detail
            chest.opacity = Double(1 - back)
            chest.translateBy(x: side * 27, y: 0)
            chest.scaleBy(x: 1 - side * 0.47 + roll * 0.18, y: 1)
            let bib = path { p in
                p.move(to: pt(-36, -129))
                p.addCurve(to: pt(-39, -93), control1: pt(-30, -115), control2: pt(-45, -106))
                p.addLine(to: pt(-30, -98)); p.addLine(to: pt(-37, -77)); p.addLine(to: pt(-28, -83))
                p.addCurve(to: pt(-19, -43), control1: pt(-29, -64), control2: pt(-18, -62))
                p.addLine(to: pt(-23, -46))
                p.addCurve(to: pt(0, -9), control1: pt(-18, -29), control2: pt(-7, -17))
                p.addCurve(to: pt(24, -46), control1: pt(8, -19), control2: pt(16, -28))
                p.addLine(to: pt(20, -43))
                p.addCurve(to: pt(31, -82), control1: pt(27, -58), control2: pt(25, -63))
                p.addLine(to: pt(39, -76)); p.addLine(to: pt(32, -99)); p.addLine(to: pt(41, -94))
                p.addCurve(to: pt(34, -130), control1: pt(34, -108), control2: pt(37, -119))
                p.closeSubpath()
            }
            chest.fill(bib, with: .linearGradient(Gradient(colors: [cream, cream, creamShade]), startPoint: pt(-15, -130), endPoint: pt(25, 3)))
            furStrokes(in: chest, center: pt(0, -80), span: 29, rows: 5, light: true)
        }
        furStrokes(in: detail, center: pt(47, -57), span: 16, rows: 4, light: false)
        if back > 0 {
            var spine = detail
            spine.opacity = Double(back * 0.6)
            let line = path { p in
                p.move(to: pt(-6, -127))
                p.addCurve(to: pt(0, -12), control1: pt(-11, -87), control2: pt(10, -45))
                p.addCurve(to: pt(9, -127), control1: pt(16, -48), control2: pt(7, -83))
                p.closeSubpath()
            }
            spine.fill(line, with: .color(stripe))
        }
    }

    private func hindLeg(in original: GraphicsContext, left: Bool) {
        let sign: CGFloat = left ? -1 : 1
        let beat = sin(motion.walkPhase + (left ? .pi : 0)) * stride
        var c = original
        c.translateBy(x: 158 + sign * (49 - side * 15) + side * 8 + curl * 20 - side * stride * 35,
                      y: 276 - max(0, beat) * 10 - curl * 3 - roll * 34)
        c.rotate(by: .degrees(Double(sign * (-5 + roll * 42) + beat * 9)))
        c.scaleBy(x: 1 + curl * 0.15, y: 1 - curl * 0.33)
        let leg = path { p in
            p.move(to: pt(-20, -53))
            p.addCurve(to: pt(-26, -11), control1: pt(-35, -43), control2: pt(-32, -23))
            p.addCurve(to: pt(-21, 8), control1: pt(-34, 0), control2: pt(-29, 7))
            p.addCurve(to: pt(20, 7), control1: pt(-9, 14), control2: pt(11, 13))
            p.addCurve(to: pt(24, -31), control1: pt(30, 0), control2: pt(27, -13))
            p.addCurve(to: pt(-20, -53), control1: pt(20, -57), control2: pt(1, -67))
            p.closeSubpath()
        }
        paint(leg, in: c, colors: [furLight, furShade], from: pt(-24, -58), to: pt(26, 10))
        var clip = c; clip.clip(to: leg)
        let cap = path { p in
            p.move(to: pt(-34, -5)); p.addCurve(to: pt(30, -4), control1: pt(-16, -19), control2: pt(12, -19))
            p.addLine(to: pt(35, 21)); p.addLine(to: pt(-36, 21)); p.closeSubpath()
        }
        clip.fill(cap, with: .linearGradient(Gradient(colors: [cream, creamShade]), startPoint: pt(0, -13), endPoint: pt(0, 16)))
        toes(in: c, y: 6, spread: 9, length: 10)
    }

    private func foreleg(in original: GraphicsContext, left: Bool) {
        let sign: CGFloat = left ? -1 : 1
        let gait = sin(motion.walkPhase + (left ? 0 : .pi)) * stride
        let waving = (!left && !reduced) ? cheer : 0
        let tuck = roll * (left ? 1 : 0.8)
        var c = original
        c.translateBy(x: 158 + sign * (25 - side * 9) + side * 12 - curl * 33 + side * stride * 22,
                      y: 197 + curl * 55 + tuck * 1)
        c.rotate(by: .degrees(Double(sign * (3 + tuck * 65) - waving * 58 + gait * 12 + curl * sign * 18)))
        c.scaleBy(x: 1 + curl * 0.13, y: 1 - curl * 0.67 - tuck * 0.3)
        let limb = path { p in
            p.move(to: pt(-17, -15))
            p.addCurve(to: pt(-18, 51), control1: pt(-22, 5), control2: pt(-15, 29))
            p.addCurve(to: pt(-25, 76), control1: pt(-16, 63), control2: pt(-27, 65))
            p.addCurve(to: pt(-14, 89), control1: pt(-28, 85), control2: pt(-24, 90))
            p.addCurve(to: pt(20, 88), control1: pt(-4, 94), control2: pt(13, 93))
            p.addCurve(to: pt(25, 72), control1: pt(29, 84), control2: pt(28, 77))
            p.addCurve(to: pt(18, 49), control1: pt(23, 62), control2: pt(18, 63))
            p.addCurve(to: pt(17, -16), control1: pt(22, 24), control2: pt(24, 2))
            p.addCurve(to: pt(-17, -15), control1: pt(9, -27), control2: pt(-8, -26))
            p.closeSubpath()
        }
        paint(limb, in: c, colors: [furLight, fur, furShade], from: pt(-18, -12), to: pt(24, 89))
        var clip = c; clip.clip(to: limb)
        for i in 0..<2 {
            let y = CGFloat(i) * 24 - 4
            let mark = path { p in
                p.move(to: pt(sign * 25, y))
                p.addCurve(to: pt(-sign * 4, y + 10), control1: pt(sign * 12, y - 4), control2: pt(sign * 2, y + 3))
                p.addCurve(to: pt(sign * 26, y + 13), control1: pt(sign * 8, y + 9), control2: pt(sign * 14, y + 16))
                p.closeSubpath()
            }
            clip.fill(mark, with: .color(stripe.opacity(0.8)))
        }
        let stocking = path { p in
            p.move(to: pt(-24, 39)); p.addLine(to: pt(-15, 44)); p.addLine(to: pt(-18, 32))
            p.addCurve(to: pt(6, 47), control1: pt(-8, 39), control2: pt(-2, 44))
            p.addLine(to: pt(11, 39)); p.addLine(to: pt(16, 47)); p.addLine(to: pt(24, 41))
            p.addLine(to: pt(34, 98)); p.addLine(to: pt(-34, 98)); p.closeSubpath()
        }
        clip.fill(stocking, with: .linearGradient(Gradient(colors: [cream, cream, creamShade]), startPoint: pt(-9, 42), endPoint: pt(15, 95)))
        toes(in: c, y: 88, spread: 9, length: 13)
        if roll > 0.1 || waving > 0.35 {
            var pads = c
            pads.opacity = Double(max(roll, waving) * 0.8)
            let pad = path { p in
                p.move(to: pt(-8, 73)); p.addCurve(to: pt(8, 73), control1: pt(-5, 66), control2: pt(4, 66))
                p.addCurve(to: pt(0, 83), control1: pt(13, 80), control2: pt(5, 86))
                p.addCurve(to: pt(-8, 73), control1: pt(-9, 87), control2: pt(-13, 79)); p.closeSubpath()
            }
            pads.fill(pad, with: .color(pink))
            for x: CGFloat in [-12, 0, 12] {
                pads.fill(Path(ellipseIn: CGRect(x: x - 3, y: 60 + abs(x) * 0.16, width: 6, height: 8)), with: .color(pink))
            }
        }
    }

    private func tail(in c: GraphicsContext) {
        let wrap = curl
        let sway = sin(t * 1.15 + 0.8) * (reduced ? 0 : 8) + pet * 8
        let tail = path { p in
            p.move(to: pt(202 + wrap * 4, 273))
            p.addCurve(to: pt(266 - wrap * 35, 229 + wrap * 30), control1: pt(244, 279), control2: pt(272, 264))
            p.addCurve(to: pt(256 - wrap * 70 + sway * (1 - wrap), 183 + wrap * 85), control1: pt(285 - wrap * 42, 181 + wrap * 94), control2: pt(268 - wrap * 60 + sway, 169 + wrap * 92))
            p.addCurve(to: pt(254 - wrap * 78 + sway * (1 - wrap), 220 + wrap * 66), control1: pt(233 - wrap * 70 + sway, 188 + wrap * 82), control2: pt(247 - wrap * 70, 202 + wrap * 86))
            p.addCurve(to: pt(200, 251 + wrap * 26), control1: pt(263 - wrap * 49, 251 + wrap * 46), control2: pt(226 - wrap * 25, 258 + wrap * 31))
            p.addCurve(to: pt(202 + wrap * 4, 273), control1: pt(190, 250 + wrap * 25), control2: pt(189, 271))
            p.closeSubpath()
        }
        paint(tail, in: c, colors: [furLight, fur, furShade], from: pt(234, 180), to: pt(264, 284))
        var clip = c; clip.clip(to: tail)
        for i in 0..<4 {
            let y = CGFloat(i) * 23 + 202
            let mark = path { p in
                p.move(to: pt(227 - wrap * 65, y))
                p.addCurve(to: pt(290, y + 7), control1: pt(252, y - 15), control2: pt(273, y - 5))
                p.addLine(to: pt(291, y + 19))
                p.addCurve(to: pt(224 - wrap * 65, y + 9), control1: pt(267, y + 6), control2: pt(246, y + 6))
                p.closeSubpath()
            }
            clip.fill(mark, with: .color(stripe.opacity(0.78)))
        }
        let tip = path { p in
            p.move(to: pt(224 - wrap * 72, 171 + wrap * 97)); p.addLine(to: pt(286, 171 + wrap * 97))
            p.addLine(to: pt(279, 200 + wrap * 74)); p.addLine(to: pt(265, 196 + wrap * 75))
            p.addLine(to: pt(261, 204 + wrap * 74)); p.addLine(to: pt(251, 197 + wrap * 75))
            p.addLine(to: pt(243, 204 + wrap * 73)); p.closeSubpath()
        }
        clip.fill(tip, with: .color(cream))
    }

    private func head(in original: GraphicsContext) {
        var c = original
        let nuzzle = reduced ? 0 : gesture.nuzzle
        let curiousTilt: CGFloat = mood == .curious ? -5 : mood == .thinking ? 4 : 0
        let idleTilt = sin(t * 0.63) * (1 - curl) * 1.3
        c.translateBy(x: 155 - curl * 38 + side * 6 + nuzzle * 9 + side * stride * 30,
                      y: 119 + curl * 115 + pet * 5 + roll * 35 + breath * 0.24 + gesture.encourage * 2 + stride * 12)
        c.rotate(by: .degrees(Double(curiousTilt + idleTilt - curl * 14 - pet * 7 + nuzzle * 10 + roll * 9 + gesture.encourage * 6)))
        c.scaleBy(x: 1 - side * 0.18 - curl * 0.07, y: 1 - curl * 0.08)
        ear(in: c, left: false)
        ear(in: c, left: true)
        let face = path { p in
            p.move(to: pt(-65, -37))
            p.addCurve(to: pt(-25, -60), control1: pt(-58, -54), control2: pt(-43, -57))
            p.addCurve(to: pt(29, -59), control1: pt(-9, -66), control2: pt(13, -65))
            p.addCurve(to: pt(71, -25), control1: pt(58, -57), control2: pt(66, -45))
            p.addCurve(to: pt(80, 9), control1: pt(80, -10), control2: pt(73, 1))
            p.addLine(to: pt(90, 15)); p.addLine(to: pt(81, 16)); p.addLine(to: pt(91, 26)); p.addLine(to: pt(81, 26))
            p.addCurve(to: pt(63, 48), control1: pt(80, 35), control2: pt(71, 43))
            p.addCurve(to: pt(0, 66), control1: pt(45, 64), control2: pt(22, 66))
            p.addCurve(to: pt(-62, 49), control1: pt(-23, 67), control2: pt(-45, 60))
            p.addCurve(to: pt(-82, 30), control1: pt(-73, 44), control2: pt(-81, 39))
            p.addLine(to: pt(-94, 28)); p.addLine(to: pt(-84, 19)); p.addLine(to: pt(-91, 18)); p.addLine(to: pt(-83, 9))
            p.addCurve(to: pt(-65, -37), control1: pt(-84, -12), control2: pt(-73, -29))
            p.closeSubpath()
        }
        paint(face, in: c, colors: [furLight, furLight, fur, furShade], from: pt(-50, -65), to: pt(70, 74), width: 2.2)
        var clip = c; clip.clip(to: face)
        // Forehead markings taper into the brow rather than forming straight graphic bars.
        for i in -1...1 {
            let x = CGFloat(i) * 24 + side * 17
            let mark = path { p in
                p.move(to: pt(x - 12, -68))
                p.addCurve(to: pt(x + 8, -12 + abs(CGFloat(i)) * 3), control1: pt(x + 1, -55), control2: pt(x + 11, -29))
                p.addCurve(to: pt(x + 4, -68), control1: pt(x + 17, -31), control2: pt(x + 11, -52))
                p.closeSubpath()
            }
            clip.fill(mark, with: .color(stripe.opacity(0.83)))
        }
        furStrokes(in: clip, center: pt(-43, -25), span: 21, rows: 4, light: false)
        furStrokes(in: clip, center: pt(45, -27), span: 20, rows: 4, light: false)
        if back < 0.99 {
            var f = clip
            f.opacity = Double(1 - smooth(min(1, back * 2)))
            f.translateBy(x: side * 38, y: 0)
            f.scaleBy(x: 1 - side * 0.29, y: 1)
            let blaze = path { p in
                p.move(to: pt(0, -35))
                p.addCurve(to: pt(-22, 2), control1: pt(-3, -15), control2: pt(-10, -7))
                p.addCurve(to: pt(-65, 24), control1: pt(-35, 16), control2: pt(-51, 19))
                p.addLine(to: pt(-80, 26)); p.addLine(to: pt(-66, 30)); p.addLine(to: pt(-84, 38))
                p.addCurve(to: pt(-45, 69), control1: pt(-75, 57), control2: pt(-63, 64))
                p.addCurve(to: pt(53, 66), control1: pt(-12, 76), control2: pt(30, 76))
                p.addCurve(to: pt(85, 34), control1: pt(70, 57), control2: pt(81, 48))
                p.addLine(to: pt(69, 30)); p.addLine(to: pt(81, 26)); p.addLine(to: pt(65, 24))
                p.addCurve(to: pt(20, 1), control1: pt(43, 22), control2: pt(29, 12))
                p.addCurve(to: pt(0, -35), control1: pt(9, -11), control2: pt(4, -20))
                p.closeSubpath()
            }
            f.fill(blaze, with: .linearGradient(Gradient(colors: [cream, cream, creamShade]), startPoint: pt(-5, -27), endPoint: pt(19, 76)))
            cheekStripes(in: f)
            eye(in: f, left: true)
            eye(in: f, left: false)
            muzzle(in: f)
            whiskers(in: f)
        }
        // Short edge glints retain the softly lit, hand-drawn character of the room.
        let glint = path { p in
            p.move(to: pt(-53, -47)); p.addCurve(to: pt(42, -52), control1: pt(-24, -68), control2: pt(18, -62))
        }
        c.stroke(glint, with: .color(cream.opacity(0.58)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    private func ear(in original: GraphicsContext, left: Bool) {
        let sign: CGFloat = left ? -1 : 1
        var c = original
        c.translateBy(x: sign * (55 - side * 8), y: -39)
        if left { c.opacity *= Double(1 - side * 0.5) }
        let flutter = reduced ? 0 : sin(t * (left ? 0.91 : 1.13) + (left ? 0 : 2)) * 1.6
        c.rotate(by: .degrees(Double(sign * (pet * 18 + curl * 5 + roll * 9) + flutter)))
        let outer = path { p in
            p.move(to: pt(-sign * 26, 1))
            p.addCurve(to: pt(sign * 12, -65), control1: pt(-sign * 14, -19), control2: pt(sign * 4, -65))
            p.addCurve(to: pt(sign * 24, -52), control1: pt(sign * 17, -69), control2: pt(sign * 22, -61))
            p.addCurve(to: pt(sign * 29, 15), control1: pt(sign * 31, -33), control2: pt(sign * 31, -7))
            p.closeSubpath()
        }
        paint(outer, in: c, colors: [furLight, furShade], from: pt(-15, -64), to: pt(20, 15), width: 2.2)
        let inner = path { p in
            p.move(to: pt(-sign * 13, -1))
            p.addCurve(to: pt(sign * 13, -55), control1: pt(-sign * 5, -20), control2: pt(sign * 7, -47))
            p.addCurve(to: pt(sign * 22, 6), control1: pt(sign * 22, -42), control2: pt(sign * 25, -12))
            p.addLine(to: pt(sign * 13, 0)); p.addLine(to: pt(sign * 15, -7)); p.addLine(to: pt(sign * 5, -2)); p.closeSubpath()
        }
        c.fill(inner, with: .linearGradient(Gradient(colors: [Color(red: 1, green: 0.78, blue: 0.64), pink]), startPoint: pt(0, -54), endPoint: pt(0, 9)))
        let light = path { p in
            p.move(to: pt(sign * 11, -55)); p.addCurve(to: pt(sign * 21, -8), control1: pt(sign * 18, -46), control2: pt(sign * 22, -26))
        }
        c.stroke(light, with: .color(cream.opacity(0.65)), style: StrokeStyle(lineWidth: 2, lineCap: .round))
    }

    private func cheekStripes(in c: GraphicsContext) {
        for sign: CGFloat in [-1, 1] {
            for i in 0..<2 {
                let y = CGFloat(i) * 17 + 6
                let marking = path { p in
                    p.move(to: pt(sign * 89, y - 8))
                    p.addCurve(to: pt(sign * 50, y + 5), control1: pt(sign * 69, y - 10), control2: pt(sign * 60, y))
                    p.addCurve(to: pt(sign * 87, y + 3), control1: pt(sign * 63, y + 9), control2: pt(sign * 79, y + 4))
                    p.closeSubpath()
                }
                c.fill(marking, with: .color(stripe.opacity(0.85)))
            }
        }
    }

    private func eye(in original: GraphicsContext, left: Bool) {
        let sign: CGFloat = left ? -1 : 1
        let squint: CGFloat = mood == .delighted ? 0.45 : mood == .thinking ? 0.2 : 0
        let closure = max(curl, max(pet * 0.91, max(blink(left: left), squint)))
        let open = max(0.035, 1 - closure)
        let concern: CGFloat = mood == .concerned ? 1 : 0
        let surprise: CGFloat = mood == .surprised ? 1 : 0
        var c = original
        if left { c.opacity *= Double(1 - side * 0.98) }
        c.translateBy(x: sign * 35, y: 8 + concern * 2)
        c.rotate(by: .degrees(Double(sign * (-7 + concern * 7))))
        let brow = path { p in
            p.move(to: pt(-10, -29 - concern * sign * 4))
            p.addCurve(to: pt(9, -31 + concern * sign * 4), control1: pt(-5, -36), control2: pt(3, -36))
        }
        c.stroke(brow, with: .color(outline.opacity(0.87)), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
        var e = c
        e.scaleBy(x: 1, y: open * (1 + surprise * 0.1))
        let eyeShape = path { p in
            p.move(to: pt(-22, 2))
            p.addCurve(to: pt(-2, -24), control1: pt(-22, -12), control2: pt(-14, -24))
            p.addCurve(to: pt(22, -2), control1: pt(13, -26), control2: pt(22, -16))
            p.addCurve(to: pt(3, 23), control1: pt(24, 13), control2: pt(15, 23))
            p.addCurve(to: pt(-22, 2), control1: pt(-12, 26), control2: pt(-23, 16)); p.closeSubpath()
        }
        e.fill(eyeShape, with: .color(Color(red: 1, green: 0.99, blue: 0.94)))
        var iris = e; iris.clip(to: eyeShape)
        let gaze = reduced ? 0 : sin(t * 0.37) * 1.2
        let irisShape = Path(ellipseIn: CGRect(x: -16 + gaze, y: -23, width: 34, height: 45))
        iris.fill(irisShape, with: .linearGradient(Gradient(colors: [Color(red: 0.23, green: 0.12, blue: 0.055), Color(red: 0.58, green: 0.29, blue: 0.04), Color(red: 1, green: 0.68, blue: 0.12)]), startPoint: pt(0, -21), endPoint: pt(0, 23)))
        iris.stroke(irisShape, with: .color(outline), lineWidth: 1.0)
        let pupilWidth: CGFloat = surprise > 0 ? 24 : 22
        iris.fill(Path(ellipseIn: CGRect(x: gaze - pupilWidth / 2, y: -22, width: pupilWidth, height: 35)), with: .color(Color(red: 0.12, green: 0.085, blue: 0.06)))
        for i in 0..<7 {
            let angle = CGFloat(i) * .pi / 9 + .pi * 0.17
            let ray = path { p in
                p.move(to: pt(cos(angle) * 12, sin(angle) * 17 + 2))
                p.addLine(to: pt(cos(angle) * 15, sin(angle) * 20 + 2))
            }
            iris.stroke(ray, with: .color(cream.opacity(0.35)), lineWidth: 0.75)
        }
        iris.fill(Path(ellipseIn: CGRect(x: -12, y: -17, width: 9, height: 11)), with: .color(.white.opacity(0.96)))
        iris.fill(Path(ellipseIn: CGRect(x: 8, y: -13, width: 5, height: 5)), with: .color(.white.opacity(0.94)))
        e.stroke(eyeShape, with: .color(outline), style: StrokeStyle(lineWidth: 2.6, lineCap: .round, lineJoin: .round))
        if closure > 0.7 {
            var lid = c; lid.opacity = Double((closure - 0.7) / 0.3)
            let line = path { p in
                p.move(to: pt(-22, 3)); p.addCurve(to: pt(21, 1), control1: pt(-9, -6), control2: pt(8, -5))
            }
            lid.stroke(line, with: .color(outline), style: StrokeStyle(lineWidth: 3.0, lineCap: .round))
        }
    }

    private func muzzle(in c: GraphicsContext) {
        let nose = path { p in
            p.move(to: pt(-8, 29))
            p.addCurve(to: pt(8, 29), control1: pt(-6, 25), control2: pt(6, 25))
            p.addCurve(to: pt(2, 36), control1: pt(12, 32), control2: pt(5, 33))
            p.addCurve(to: pt(-2, 36), control1: pt(1, 39), control2: pt(-1, 39))
            p.addCurve(to: pt(-8, 29), control1: pt(-5, 34), control2: pt(-12, 32)); p.closeSubpath()
        }
        paint(nose, in: c, colors: [Color(red: 1, green: 0.76, blue: 0.62), pink, Color(red: 0.76, green: 0.39, blue: 0.29)], from: pt(0, 27), to: pt(0, 39), width: 1.5)
        c.stroke(path { p in p.move(to: pt(-4, 29)); p.addQuadCurve(to: pt(3, 29), control: pt(0, 27)) }, with: .color(cream.opacity(0.8)), style: StrokeStyle(lineWidth: 1.3, lineCap: .round))
        let speech = gesture.mouth
        let happyOpen: CGFloat = mood == .delighted ? 0.45 + cheer * 0.3 : 0
        let open = max(speech, happyOpen) * (1 - curl) * (1 - pet)
        if open > 0.01 {
            let mouth = path { p in
                p.move(to: pt(-12, 44)); p.addQuadCurve(to: pt(12, 44), control: pt(0, 49))
                p.addCurve(to: pt(0, 47 + open * 21), control1: pt(11, 55 + open * 14), control2: pt(5, 47 + open * 21))
                p.addCurve(to: pt(-12, 44), control1: pt(-6, 47 + open * 21), control2: pt(-11, 55 + open * 14)); p.closeSubpath()
            }
            c.fill(mouth, with: .color(outline))
            var mouthClip = c; mouthClip.clip(to: mouth)
            mouthClip.fill(Path(ellipseIn: CGRect(x: -8, y: 48 + open * 10, width: 16, height: 12)), with: .color(pink))
        }
        let smile = path { p in
            p.move(to: pt(0, 37)); p.addQuadCurve(to: pt(-1, 44), control: pt(0, 41))
            p.addCurve(to: pt(-18, 44), control1: pt(-7, 52), control2: pt(-14, 50))
            p.move(to: pt(-1, 44)); p.addCurve(to: pt(18, 43), control1: pt(6, 52), control2: pt(14, 50))
        }
        c.stroke(smile, with: .color(outline), style: StrokeStyle(lineWidth: 2.1, lineCap: .round, lineJoin: .round))
        for sign: CGFloat in [-1, 1] {
            for i in 0..<3 {
                c.fill(Path(ellipseIn: CGRect(x: sign * (24 + CGFloat(i % 2) * 6) - 0.7, y: 34 + CGFloat(i) * 4, width: 1.4, height: 1.4)), with: .color(stripe.opacity(0.46)))
            }
        }
    }

    private func whiskers(in c: GraphicsContext) {
        for sign: CGFloat in [-1, 1] {
            for i in 0..<3 {
                let index = CGFloat(i)
                let line = path { p in
                    p.move(to: pt(sign * (48 + index * 2), 31 + index * 6))
                    p.addQuadCurve(to: pt(sign * (99 - index * 3), 26 + index * 16), control: pt(sign * 78, 24 + index * 12))
                }
                c.stroke(line, with: .color(outline.opacity(0.7 - Double(i) * 0.12)), style: StrokeStyle(lineWidth: 1.05, lineCap: .round))
            }
        }
    }

    private func blink(left: Bool) -> CGFloat {
        guard !reduced else { return 0 }
        // Unequal intervals and a small inter-eye delay avoid a mechanical metronome blink.
        let shifted = t + (left ? 0 : 0.023)
        let cycle = shifted.truncatingRemainder(dividingBy: 11.3)
        let first = max(0, 1 - abs(cycle - 3.8) / 0.16)
        let second = max(0, 1 - abs(cycle - 8.65) / 0.19)
        let doubleBlink = max(0, 1 - abs(cycle - 9.1) / 0.13) * 0.82
        return smooth(max(first, max(second, doubleBlink)))
    }

    private func toes(in c: GraphicsContext, y: CGFloat, spread: CGFloat, length: CGFloat) {
        for x in [-spread, spread] {
            let seam = path { p in
                p.move(to: pt(x, y)); p.addQuadCurve(to: pt(x - 1.5, y - length), control: pt(x - 3, y - length * 0.45))
            }
            c.stroke(seam, with: .color(outline.opacity(0.65)), style: StrokeStyle(lineWidth: 1.25, lineCap: .round))
        }
    }

    private func furStrokes(in c: GraphicsContext, center: CGPoint, span: CGFloat, rows: Int, light: Bool) {
        for row in 0..<rows {
            for column in 0..<5 {
                let offset = CGFloat(column) / 4 * span * 2 - span
                let x = center.x + offset + (row % 2 == 0 ? 2 : -2)
                let y = center.y + CGFloat(row) * 7
                let mark = path { p in
                    p.move(to: pt(x, y))
                    p.addQuadCurve(to: pt(x + offset * 0.1, y + 5), control: pt(x + offset * 0.08 + 1, y + 3))
                }
                c.stroke(mark, with: .color((light ? creamShade : cream).opacity(light ? 0.32 : 0.19)), style: StrokeStyle(lineWidth: 0.7, lineCap: .round))
            }
        }
    }

    private func paint(_ path: Path, in c: GraphicsContext, colors: [Color], from: CGPoint, to: CGPoint, width: CGFloat = 1.85) {
        c.fill(path, with: .linearGradient(Gradient(colors: colors), startPoint: from, endPoint: to))
        c.stroke(path, with: .color(outline), style: StrokeStyle(lineWidth: width, lineCap: .round, lineJoin: .round))
    }

    private func path(_ body: (inout Path) -> Void) -> Path { Path(body) }
    private func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
    private func unit(_ x: CGFloat) -> CGFloat { min(1, max(0, x)) }
    private func smooth(_ x: CGFloat) -> CGFloat { let x = unit(x); return x * x * (3 - 2 * x) }
}
