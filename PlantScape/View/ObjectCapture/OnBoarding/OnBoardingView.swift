//
//  OnBoardingView.swift
//  PlantScape
//
//  Created by Mohammad Zhafran Dzaky on 06/06/24.
//

import Foundation
import RealityKit
import SwiftUI

@available(iOS 17.0, *)
/// View that shows the guidance text and tutorials on the review screen.
struct OnboardingView: View {
    @EnvironmentObject var appModel: AppDataModel
    @StateObject private var stateMachine: OnboardingStateMachine
    @Environment(\.colorScheme) private var colorScheme

    init(state: OnboardingState) {
        _stateMachine = StateObject(wrappedValue: OnboardingStateMachine(state))
    }

    var body: some View {
        ZStack {
            Color(colorScheme == .light ? .white : .black).ignoresSafeArea()
            if let session = appModel.objectCaptureSession {
                OnboardingTutorialView(session: session, onboardingStateMachine: stateMachine)
                OnboardingButtonView(session: session, onboardingStateMachine: stateMachine)
            }
        }
        .interactiveDismissDisabled(appModel.objectCaptureSession?.userCompletedScanPass ?? false)
        .allowsHitTesting(!isFinishingOrCompleted)
    }

    private var isFinishingOrCompleted: Bool {
        guard let session = appModel.objectCaptureSession else { return true }
        return session.state == .finishing || session.state == .completed
    }
}
