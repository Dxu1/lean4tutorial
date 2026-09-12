import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.FixedTightness

/-!
# MP1994 v2: pairwise orders across existing reduced equilibria

No theorem in this file constructs an equilibrium or uses
`StaticExistenceAssumptions`.
-/

namespace MP1994V2

theorem jobCreation_curve_antitone
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    {theta1 theta2 d1 d2 : ℝ}
    (htheta1 : 0 < theta1) (htheta2 : 0 < theta2)
    (hd1 : d1 < P.epsUpper) (hd2 : d2 < P.epsUpper)
    (hJC1 : P.SatisfiesJobCreationProduct theta1 d1)
    (hJC2 : P.SatisfiesJobCreationProduct theta2 d2)
    (hd : d1 ≤ d2) :
    theta2 ≤ theta1 := by
  by_contra hnot
  have htheta : theta1 < theta2 := lt_of_not_ge hnot
  have hq := M.vacancyMeetingRate_strictAntiOn htheta1 htheta2 htheta
  change P.q theta2 < P.q theta1 at hq
  have hq1 := M.vacancyMeetingRate_pos htheta1
  have hq2 := M.vacancyMeetingRate_pos htheta2
  change 0 < P.q theta1 at hq1
  change 0 < P.q theta2 at hq2
  have hgap1 : 0 < P.epsUpper - d1 := sub_pos.mpr hd1
  have hgap2 : 0 < P.epsUpper - d2 := sub_pos.mpr hd2
  have hgap : P.epsUpper - d2 ≤ P.epsUpper - d1 := by linarith
  have hp : P.q theta2 * (P.epsUpper - d2) <
      P.q theta1 * (P.epsUpper - d1) :=
    calc
      P.q theta2 * (P.epsUpper - d2) <
          P.q theta1 * (P.epsUpper - d2) :=
        mul_lt_mul_of_pos_right hq hgap2
      _ ≤ P.q theta1 * (P.epsUpper - d1) :=
        mul_le_mul_of_nonneg_left hgap hq1.le
  have hs := P.jobCreationScale_pos A
  unfold Primitives.SatisfiesJobCreationProduct at hJC1 hJC2
  unfold Primitives.jobCreationScale at hs
  nlinarith [mul_lt_mul_of_pos_right hp hs]

namespace ReducedEquilibrium

theorem order_of_commonProductivity
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {pLow pHigh : ℝ} (hp : pLow < pHigh)
    (RLow : ReducedEquilibrium (P.withCommonProductivity pLow))
    (RHigh : ReducedEquilibrium (P.withCommonProductivity pHigh)) :
    RHigh.cutoff < RLow.cutoff ∧ RLow.theta < RHigh.theta := by
  let PL := P.withCommonProductivity pLow
  let PH := P.withCommonProductivity pHigh
  have AL := A.withCommonProductivity pLow
  have AH := A.withCommonProductivity pHigh
  have DL := D.withCommonProductivity pLow
  have hCut : RHigh.cutoff < RLow.cutoff := by
    by_contra hnot
    have hd : RLow.cutoff ≤ RHigh.cutoff := le_of_not_gt hnot
    have hTheta : RLow.theta < RHigh.theta := by
      rw [(PL.satisfiesJobDestructionMeasure_iff AL _ _).mp
          RLow.jobDestructionMeasure,
        (PH.satisfiesJobDestructionMeasure_iff AH _ _).mp
          RHigh.jobDestructionMeasure]
      unfold Primitives.jobDestructionTheta
      apply div_lt_div_of_pos_right _ (P.searchOpportunityCostCoefficient_pos A)
      calc
        PL.jobDestructionNet RLow.cutoff ≤
            PL.jobDestructionNet RHigh.cutoff :=
          (PL.jobDestructionNet_strictMono AL DL).monotone hd
        _ < PH.jobDestructionNet RHigh.cutoff := by
          unfold PL PH Primitives.withCommonProductivity
            Primitives.jobDestructionNet Primitives.expectedExcess
          simp only
          linarith
    have hJCL : P.SatisfiesJobCreationProduct RLow.theta RLow.cutoff := by
      simpa [PL, Primitives.withCommonProductivity,
        Primitives.SatisfiesJobCreationProduct] using RLow.jobCreationProduct
    have hJCH : P.SatisfiesJobCreationProduct RHigh.theta RHigh.cutoff := by
      simpa [PH, Primitives.withCommonProductivity,
        Primitives.SatisfiesJobCreationProduct] using RHigh.jobCreationProduct
    have hThetaOpp := jobCreation_curve_antitone A M
      RLow.theta_pos RHigh.theta_pos RLow.cutoff_lt_epsUpper
      RHigh.cutoff_lt_epsUpper hJCL hJCH hd
    exact (not_lt_of_ge hThetaOpp) hTheta
  have hJCH : P.SatisfiesJobCreationProduct RHigh.theta RHigh.cutoff := by
    simpa [PH, Primitives.withCommonProductivity,
      Primitives.SatisfiesJobCreationProduct] using RHigh.jobCreationProduct
  have hJCL : P.SatisfiesJobCreationProduct RLow.theta RLow.cutoff := by
    simpa [PL, Primitives.withCommonProductivity,
      Primitives.SatisfiesJobCreationProduct] using RLow.jobCreationProduct
  exact ⟨hCut, jobCreation_curve_strictAnti A M
    RHigh.theta_pos RLow.theta_pos RHigh.cutoff_lt_epsUpper
    RLow.cutoff_lt_epsUpper hJCH hJCL hCut⟩

theorem order_of_unemploymentIncome
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {bLow bHigh : ℝ} (hb : bLow < bHigh)
    (RLow : ReducedEquilibrium (P.withUnemploymentIncome bLow))
    (RHigh : ReducedEquilibrium (P.withUnemploymentIncome bHigh)) :
    RLow.cutoff < RHigh.cutoff ∧ RHigh.theta < RLow.theta := by
  let PL := P.withUnemploymentIncome bLow
  let PH := P.withUnemploymentIncome bHigh
  have AL := A.withUnemploymentIncome bLow
  have AH := A.withUnemploymentIncome bHigh
  have DH := D.withUnemploymentIncome bHigh
  have hCut : RLow.cutoff < RHigh.cutoff := by
    by_contra hnot
    have hd : RHigh.cutoff ≤ RLow.cutoff := le_of_not_gt hnot
    have hTheta : RHigh.theta < RLow.theta := by
      rw [(PH.satisfiesJobDestructionMeasure_iff AH _ _).mp
          RHigh.jobDestructionMeasure,
        (PL.satisfiesJobDestructionMeasure_iff AL _ _).mp
          RLow.jobDestructionMeasure]
      unfold Primitives.jobDestructionTheta
      apply div_lt_div_of_pos_right _ (P.searchOpportunityCostCoefficient_pos A)
      calc
        PH.jobDestructionNet RHigh.cutoff ≤
            PH.jobDestructionNet RLow.cutoff :=
          (PH.jobDestructionNet_strictMono AH DH).monotone hd
        _ < PL.jobDestructionNet RLow.cutoff := by
          unfold PL PH Primitives.withUnemploymentIncome
            Primitives.jobDestructionNet Primitives.expectedExcess
          simp only
          linarith
    have hJCH : P.SatisfiesJobCreationProduct RHigh.theta RHigh.cutoff := by
      simpa [PH, Primitives.withUnemploymentIncome,
        Primitives.SatisfiesJobCreationProduct] using RHigh.jobCreationProduct
    have hJCL : P.SatisfiesJobCreationProduct RLow.theta RLow.cutoff := by
      simpa [PL, Primitives.withUnemploymentIncome,
        Primitives.SatisfiesJobCreationProduct] using RLow.jobCreationProduct
    have hThetaOpp := jobCreation_curve_antitone A M
      RHigh.theta_pos RLow.theta_pos RHigh.cutoff_lt_epsUpper
      RLow.cutoff_lt_epsUpper hJCH hJCL hd
    exact (not_lt_of_ge hThetaOpp) hTheta
  have hJCL : P.SatisfiesJobCreationProduct RLow.theta RLow.cutoff := by
    simpa [PL, Primitives.withUnemploymentIncome,
      Primitives.SatisfiesJobCreationProduct] using RLow.jobCreationProduct
  have hJCH : P.SatisfiesJobCreationProduct RHigh.theta RHigh.cutoff := by
    simpa [PH, Primitives.withUnemploymentIncome,
      Primitives.SatisfiesJobCreationProduct] using RHigh.jobCreationProduct
  exact ⟨hCut, jobCreation_curve_strictAnti A M
    RLow.theta_pos RHigh.theta_pos RLow.cutoff_lt_epsUpper
    RHigh.cutoff_lt_epsUpper hJCL hJCH hCut⟩

theorem cutoff_strictAnti_shockArrival
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {lambdaLow lambdaHigh : ℝ}
    (hlow : 0 ≤ lambdaLow) (hlambda : lambdaLow < lambdaHigh)
    (RLow : ReducedEquilibrium (P.withShockArrivalRate lambdaLow))
    (RHigh : ReducedEquilibrium (P.withShockArrivalRate lambdaHigh)) :
    RHigh.cutoff < RLow.cutoff := by
  let PL := P.withShockArrivalRate lambdaLow
  let PH := P.withShockArrivalRate lambdaHigh
  have hhigh : 0 ≤ lambdaHigh := hlow.trans hlambda.le
  have AL := A.withShockArrivalRate lambdaLow hlow
  have AH := A.withShockArrivalRate lambdaHigh hhigh
  have DH := D.withShockArrivalRate lambdaHigh
  have hFrac := shockArrivalFraction_monotone A.r_pos hlow hlambda.le
  by_contra hnot
  have hd : RLow.cutoff ≤ RHigh.cutoff := le_of_not_gt hnot
  have hThetaJD : RLow.theta ≤ RHigh.theta := by
    rw [(PL.satisfiesJobDestructionMeasure_iff AL _ _).mp
        RLow.jobDestructionMeasure,
      (PH.satisfiesJobDestructionMeasure_iff AH _ _).mp
        RHigh.jobDestructionMeasure]
    unfold Primitives.jobDestructionTheta
    apply div_le_div_of_nonneg_right _ (P.searchOpportunityCostCoefficient_pos A).le
    calc
      PL.jobDestructionNet RLow.cutoff ≤ PH.jobDestructionNet RLow.cutoff := by
        have hE := P.expectedExcess_nonneg RLow.cutoff
        have hw := mul_le_mul_of_nonneg_right hFrac
          (mul_nonneg A.sigma_pos.le hE)
        unfold PL PH Primitives.withShockArrivalRate
          Primitives.jobDestructionNet Primitives.expectedExcess at *
        simp only at hw ⊢
        have hw' :
            lambdaLow * P.sigma / (P.r + lambdaLow) *
                (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) ≤
              lambdaHigh * P.sigma / (P.r + lambdaHigh) *
                (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by
          calc
            lambdaLow * P.sigma / (P.r + lambdaLow) *
                (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) =
                (lambdaLow / (P.r + lambdaLow)) *
                  (P.sigma * ∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by ring
            _ ≤ _ := hw
            _ = lambdaHigh * P.sigma / (P.r + lambdaHigh) *
                (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by ring
        linarith
      _ ≤ PH.jobDestructionNet RHigh.cutoff :=
        (PH.jobDestructionNet_strictMono AH DH).monotone hd
  have hScale : PH.jobCreationScale < PL.jobCreationScale := by
    unfold PL PH Primitives.withShockArrivalRate
      Primitives.jobCreationScale
    have hdenLow : 0 < P.r + lambdaLow :=
      add_pos_of_pos_of_nonneg A.r_pos hlow
    have hdenHigh : 0 < P.r + lambdaHigh :=
      add_pos_of_pos_of_nonneg A.r_pos hhigh
    have hdiv : P.sigma / (P.r + lambdaHigh) <
        P.sigma / (P.r + lambdaLow) :=
      div_lt_div_of_pos_left A.sigma_pos hdenLow (by linarith)
    exact mul_lt_mul_of_pos_left hdiv A.one_sub_beta_pos
  have hq : P.q RLow.theta < P.q RHigh.theta := by
    have hgapLow : 0 < P.epsUpper - RLow.cutoff :=
      sub_pos.mpr RLow.cutoff_lt_epsUpper
    have hgapHigh : 0 < P.epsUpper - RHigh.cutoff :=
      sub_pos.mpr RHigh.cutoff_lt_epsUpper
    have hgap : P.epsUpper - RHigh.cutoff ≤
        P.epsUpper - RLow.cutoff := by linarith
    have hprod : PH.jobCreationScale * (P.epsUpper - RHigh.cutoff) <
        PL.jobCreationScale * (P.epsUpper - RLow.cutoff) :=
      calc
        PH.jobCreationScale * (P.epsUpper - RHigh.cutoff) <
            PL.jobCreationScale * (P.epsUpper - RHigh.cutoff) :=
          mul_lt_mul_of_pos_right hScale hgapHigh
        _ ≤ PL.jobCreationScale * (P.epsUpper - RLow.cutoff) :=
          mul_le_mul_of_nonneg_left hgap (PL.jobCreationScale_pos AL).le
    have hJDL :
        P.q RLow.theta * PL.jobCreationScale *
            (P.epsUpper - RLow.cutoff) = P.c := by
      simpa [PL, Primitives.withShockArrivalRate,
        Primitives.SatisfiesJobCreationProduct,
        Primitives.jobCreationScale, mul_assoc] using
        RLow.jobCreationProduct
    have hJDH :
        P.q RHigh.theta * PH.jobCreationScale *
            (P.epsUpper - RHigh.cutoff) = P.c := by
      simpa [PH, Primitives.withShockArrivalRate,
        Primitives.SatisfiesJobCreationProduct,
        Primitives.jobCreationScale, mul_assoc] using
        RHigh.jobCreationProduct
    have hqHigh : 0 < P.q RHigh.theta := M.vacancyMeetingRate_pos RHigh.theta_pos
    by_contra hn
    have hqle : P.q RHigh.theta ≤ P.q RLow.theta := le_of_not_gt hn
    have hFullAssoc :
        P.q RHigh.theta *
            (PH.jobCreationScale * (P.epsUpper - RHigh.cutoff)) <
          P.q RLow.theta *
            (PL.jobCreationScale * (P.epsUpper - RLow.cutoff)) := by
      calc
        P.q RHigh.theta *
            (PH.jobCreationScale * (P.epsUpper - RHigh.cutoff)) <
            P.q RHigh.theta *
              (PL.jobCreationScale * (P.epsUpper - RLow.cutoff)) :=
          mul_lt_mul_of_pos_left hprod hqHigh
        _ ≤ P.q RLow.theta *
              (PL.jobCreationScale * (P.epsUpper - RLow.cutoff)) :=
          mul_le_mul_of_nonneg_right hqle
            (mul_nonneg (PL.jobCreationScale_pos AL).le hgapLow.le)
    have hFull :
        P.q RHigh.theta * PH.jobCreationScale *
            (P.epsUpper - RHigh.cutoff) <
          P.q RLow.theta * PL.jobCreationScale *
            (P.epsUpper - RLow.cutoff) := by
      simpa [mul_assoc] using hFullAssoc
    rw [hJDH, hJDL] at hFull
    exact (lt_irrefl P.c) hFull
  have hThetaJC : RHigh.theta < RLow.theta := by
    by_contra hn
    have hle : RLow.theta ≤ RHigh.theta := le_of_not_gt hn
    have hqle : P.q RHigh.theta ≤ P.q RLow.theta := by
      rcases hle.eq_or_lt with heq | hlt
      · rw [heq]
      · exact (M.vacancyMeetingRate_strictAntiOn
          RLow.theta_pos RHigh.theta_pos hlt).le
    exact (not_lt_of_ge hqle) hq
  exact (not_lt_of_ge hThetaJD) hThetaJC

theorem theta_strictAnti_discountRate
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {rLow rHigh : ℝ}
    (hrLow : 0 < rLow) (hr : rLow < rHigh)
    (RLow : ReducedEquilibrium (P.withDiscountRate rLow))
    (RHigh : ReducedEquilibrium (P.withDiscountRate rHigh)) :
    RHigh.theta < RLow.theta := by
  let PL := P.withDiscountRate rLow
  let PH := P.withDiscountRate rHigh
  have AL := A.withDiscountRate rLow hrLow
  have AH := A.withDiscountRate rHigh (hrLow.trans hr)
  have DH := D.withDiscountRate rHigh
  have hFrac := discountFraction_antitone A.lambda_nonneg hrLow hr.le
  by_contra hnot
  have htheta : RLow.theta ≤ RHigh.theta := le_of_not_gt hnot
  have hCut : RLow.cutoff ≤ RHigh.cutoff := by
    have hNetAtLow : PH.jobDestructionNet RLow.cutoff ≤
        PL.jobDestructionNet RLow.cutoff := by
      have hE := P.expectedExcess_nonneg RLow.cutoff
      have hw := mul_le_mul_of_nonneg_right hFrac
        (mul_nonneg A.sigma_pos.le hE)
      unfold PL PH Primitives.withDiscountRate
        Primitives.jobDestructionNet Primitives.expectedExcess at *
      simp only at hw ⊢
      have hw' :
          P.lambda * P.sigma / (rHigh + P.lambda) *
              (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) ≤
            P.lambda * P.sigma / (rLow + P.lambda) *
              (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by
        calc
          P.lambda * P.sigma / (rHigh + P.lambda) *
              (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) =
              (P.lambda / (rHigh + P.lambda)) *
                (P.sigma * ∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by ring
          _ ≤ _ := hw
          _ = P.lambda * P.sigma / (rLow + P.lambda) *
              (∫ x, positivePart (x - RLow.cutoff) ∂P.shock) := by ring
      linarith
    have hNetLowEq : PL.jobDestructionNet RLow.cutoff =
        P.searchOpportunityCostCoefficient * RLow.theta := by
      have h := RLow.jobDestructionMeasure
      unfold Primitives.SatisfiesJobDestructionMeasure
        Primitives.jobDestructionResidualMeasure at h
      unfold PL Primitives.withDiscountRate Primitives.jobDestructionNet
        Primitives.searchOpportunityCostCoefficient Primitives.expectedExcess
      simp only
      simp [Primitives.withDiscountRate, Primitives.expectedExcess] at h
      linarith
    have hNetHighEq : PH.jobDestructionNet RHigh.cutoff =
        P.searchOpportunityCostCoefficient * RHigh.theta := by
      have h := RHigh.jobDestructionMeasure
      unfold Primitives.SatisfiesJobDestructionMeasure
        Primitives.jobDestructionResidualMeasure at h
      unfold PH Primitives.withDiscountRate Primitives.jobDestructionNet
        Primitives.searchOpportunityCostCoefficient Primitives.expectedExcess
      simp only
      simp [Primitives.withDiscountRate, Primitives.expectedExcess] at h
      linarith
    have hNetOrder : PH.jobDestructionNet RLow.cutoff ≤
        PH.jobDestructionNet RHigh.cutoff := by
      calc
        PH.jobDestructionNet RLow.cutoff ≤ PL.jobDestructionNet RLow.cutoff := hNetAtLow
        _ = P.searchOpportunityCostCoefficient * RLow.theta := hNetLowEq
        _ ≤ P.searchOpportunityCostCoefficient * RHigh.theta :=
          mul_le_mul_of_nonneg_left htheta
            (P.searchOpportunityCostCoefficient_pos A).le
        _ = PH.jobDestructionNet RHigh.cutoff := hNetHighEq.symm
    exact (PH.jobDestructionNet_strictMono AH DH).le_iff_le.mp hNetOrder
  have hq : P.q RHigh.theta ≤ P.q RLow.theta := by
    rcases htheta.eq_or_lt with heq | hlt
    · simp [heq]
    · exact (M.vacancyMeetingRate_strictAntiOn RLow.theta_pos
        RHigh.theta_pos hlt).le
  have hScale : PH.jobCreationScale < PL.jobCreationScale := by
    unfold PL PH Primitives.withDiscountRate Primitives.jobCreationScale
    have hdenLow : 0 < rLow + P.lambda :=
      add_pos_of_pos_of_nonneg hrLow A.lambda_nonneg
    have hdiv : P.sigma / (rHigh + P.lambda) <
        P.sigma / (rLow + P.lambda) :=
      div_lt_div_of_pos_left A.sigma_pos hdenLow (by linarith)
    exact mul_lt_mul_of_pos_left hdiv A.one_sub_beta_pos
  have hgap : P.epsUpper - RHigh.cutoff ≤
      P.epsUpper - RLow.cutoff := by linarith
  have hgapHigh : 0 < P.epsUpper - RHigh.cutoff :=
    sub_pos.mpr RHigh.cutoff_lt_epsUpper
  have hScaleLow := PL.jobCreationScale_pos AL
  have hProd :
      P.q RHigh.theta * PH.jobCreationScale *
          (P.epsUpper - RHigh.cutoff) <
        P.q RLow.theta * PL.jobCreationScale *
          (P.epsUpper - RLow.cutoff) := by
    have hqLow : 0 < P.q RLow.theta := M.vacancyMeetingRate_pos RLow.theta_pos
    have hqHigh : 0 < P.q RHigh.theta := M.vacancyMeetingRate_pos RHigh.theta_pos
    calc
      P.q RHigh.theta * PH.jobCreationScale *
          (P.epsUpper - RHigh.cutoff) <
          P.q RHigh.theta * PL.jobCreationScale *
            (P.epsUpper - RHigh.cutoff) := by
        exact mul_lt_mul_of_pos_right
          (mul_lt_mul_of_pos_left hScale hqHigh) hgapHigh
      _ ≤ P.q RLow.theta * PL.jobCreationScale *
            (P.epsUpper - RHigh.cutoff) := by
        exact mul_le_mul_of_nonneg_right
          (mul_le_mul_of_nonneg_right hq (PL.jobCreationScale_pos AL).le)
          hgapHigh.le
      _ ≤ P.q RLow.theta * PL.jobCreationScale *
            (P.epsUpper - RLow.cutoff) := by
        exact mul_le_mul_of_nonneg_left hgap
          (mul_nonneg hqLow.le (PL.jobCreationScale_pos AL).le)
  have hJCL := RLow.jobCreationProduct
  have hJCH := RHigh.jobCreationProduct
  unfold Primitives.SatisfiesJobCreationProduct at hJCL hJCH
  unfold Primitives.jobCreationScale at hProd
  simp [PL, PH, Primitives.withDiscountRate] at hProd
  simp [Primitives.withDiscountRate] at hJCL hJCH
  ring_nf at hProd hJCL hJCH
  nlinarith

end ReducedEquilibrium

end MP1994V2
