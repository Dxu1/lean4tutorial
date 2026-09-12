import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.ExpectedExcessProperties

/-!
# MP1994 v2: static job-destruction and job-creation curves

The two robust M3 conditions are scalarized along the job-destruction curve.
No equilibrium or crossing is assumed in this module.
-/

open Set

namespace MP1994V2

namespace Primitives

variable {P : Primitives}

/-- Coefficient on market tightness in measure-form equation (10). -/
noncomputable def searchOpportunityCostCoefficient (P : Primitives) : ℝ :=
  P.beta * P.c / (1 - P.beta)

/-- Scale multiplying the productivity gap in robust equation (13). -/
noncomputable def jobCreationScale (P : Primitives) : ℝ :=
  (1 - P.beta) * (P.sigma / (P.r + P.lambda))

theorem searchOpportunityCostCoefficient_pos
    (A : CoreEconomicAssumptions P) :
    0 < P.searchOpportunityCostCoefficient := by
  exact div_pos (mul_pos A.beta_pos A.c_pos) A.one_sub_beta_pos

theorem searchOpportunityCostCoefficient_ne
    (A : CoreEconomicAssumptions P) :
    P.searchOpportunityCostCoefficient ≠ 0 :=
  (P.searchOpportunityCostCoefficient_pos A).ne'

theorem jobCreationScale_pos
    (A : CoreEconomicAssumptions P) :
    0 < P.jobCreationScale := by
  exact mul_pos A.one_sub_beta_pos
    (div_pos A.sigma_pos A.r_add_lambda_pos)

theorem jobCreationScale_ne
    (A : CoreEconomicAssumptions P) :
    P.jobCreationScale ≠ 0 :=
  (P.jobCreationScale_pos A).ne'

/-- Net value on the right side of rearranged equation (10). -/
noncomputable def jobDestructionNet (P : Primitives) (d : ℝ) : ℝ :=
  P.p + P.sigma * d - P.b
    + (P.lambda * P.sigma / (P.r + P.lambda)) * P.expectedExcess d

/-- Market tightness implied by equation (10) at cutoff `d`. -/
noncomputable def jobDestructionTheta (P : Primitives) (d : ℝ) : ℝ :=
  P.jobDestructionNet d / P.searchOpportunityCostCoefficient

/-- The robust M3 job-destruction equation is exactly the graph of
`jobDestructionTheta`. -/
theorem satisfiesJobDestructionMeasure_iff
    (A : CoreEconomicAssumptions P) (theta d : ℝ) :
    P.SatisfiesJobDestructionMeasure theta d ↔
      theta = P.jobDestructionTheta d := by
  have hk := P.searchOpportunityCostCoefficient_ne A
  unfold SatisfiesJobDestructionMeasure jobDestructionResidualMeasure
    jobDestructionTheta
  constructor
  · intro h
    apply (eq_div_iff hk).2
    unfold jobDestructionNet searchOpportunityCostCoefficient at *
    ring_nf at h ⊢
    linarith
  · intro h
    have hm := (eq_div_iff hk).1 h
    unfold jobDestructionNet searchOpportunityCostCoefficient at *
    ring_nf at hm ⊢
    linarith

/-- The net job-destruction value rises strictly with the cutoff.  The proof
uses the one-Lipschitz lower bound on expected excess and no derivatives. -/
theorem jobDestructionNet_strictMono
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) :
    StrictMono P.jobDestructionNet := by
  intro d1 d2 hd
  have hLip := (P.expectedExcess_lipschitz D).dist_le_mul d1 d2
  have hAbs :
      |P.expectedExcess d2 - P.expectedExcess d1| ≤ d2 - d1 := by
    have hdist : dist d1 d2 = d2 - d1 := by
      rw [Real.dist_eq, abs_of_neg (sub_neg.mpr hd)]
      ring
    rw [abs_sub_comm]
    simpa [Real.dist_eq, hdist] using hLip
  have hLower :
      -(d2 - d1) ≤ P.expectedExcess d2 - P.expectedExcess d1 :=
    (neg_le_of_abs_le hAbs)
  let k := P.lambda * P.sigma / (P.r + P.lambda)
  have hk : 0 ≤ k := by
    dsimp [k]
    exact div_nonneg (mul_nonneg A.lambda_nonneg A.sigma_pos.le)
      A.r_add_lambda_pos.le
  have hWeighted := mul_le_mul_of_nonneg_left hLower hk
  have hMargin : 0 < P.sigma - k := by
    dsimp [k]
    rw [show P.sigma - P.lambda * P.sigma / (P.r + P.lambda) =
        P.sigma * P.r / (P.r + P.lambda) by
      field_simp [A.r_add_lambda_ne]
      ring]
    exact div_pos (mul_pos A.sigma_pos A.r_pos) A.r_add_lambda_pos
  unfold jobDestructionNet
  nlinarith

theorem jobDestructionTheta_strictMono
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) :
    StrictMono P.jobDestructionTheta := by
  intro d1 d2 hd
  unfold jobDestructionTheta
  exact div_lt_div_of_pos_right
    (P.jobDestructionNet_strictMono A D hd)
    (P.searchOpportunityCostCoefficient_pos A)

theorem jobDestructionTheta_continuous
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P) :
    Continuous P.jobDestructionTheta := by
  unfold jobDestructionTheta jobDestructionNet
  have hE : Continuous P.expectedExcess := P.expectedExcess_continuous D
  fun_prop

/-- Equation (13), in robust product form, evaluated along the JD curve. -/
noncomputable def staticCrossingResidual (P : Primitives) (d : ℝ) : ℝ :=
  P.q (P.jobDestructionTheta d) * P.jobCreationScale *
      (P.epsUpper - d) - P.c

/-- Domain on which both static curves have their economic interpretation. -/
def IsAdmissibleStaticCutoff (P : Primitives) (d : ℝ) : Prop :=
  0 < P.jobDestructionTheta d ∧ d < P.epsUpper

theorem staticCrossingResidual_epsUpper (P : Primitives) :
    P.staticCrossingResidual P.epsUpper = -P.c := by
  unfold staticCrossingResidual
  ring

theorem staticCrossingResidual_epsUpper_neg
    (A : CoreEconomicAssumptions P) :
    P.staticCrossingResidual P.epsUpper < 0 := by
  rw [P.staticCrossingResidual_epsUpper]
  linarith [A.c_pos]

/-- Pairwise form of strict decrease of the scalar crossing residual. -/
theorem staticCrossingResidual_lt_of_lt
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P)
    {d1 d2 : ℝ}
    (h1 : P.IsAdmissibleStaticCutoff d1)
    (h2 : P.IsAdmissibleStaticCutoff d2)
    (hd : d1 < d2) :
    P.staticCrossingResidual d2 < P.staticCrossingResidual d1 := by
  have hTheta := P.jobDestructionTheta_strictMono A D hd
  have hq := M.vacancyMeetingRate_strictAntiOn h1.1 h2.1 hTheta
  change P.q (P.jobDestructionTheta d2) <
    P.q (P.jobDestructionTheta d1) at hq
  have hq1 := M.vacancyMeetingRate_pos h1.1
  have hq2 := M.vacancyMeetingRate_pos h2.1
  change 0 < P.q (P.jobDestructionTheta d1) at hq1
  change 0 < P.q (P.jobDestructionTheta d2) at hq2
  have hgap1 : 0 < P.epsUpper - d1 := sub_pos.mpr h1.2
  have hgap2 : 0 < P.epsUpper - d2 := sub_pos.mpr h2.2
  have hgap : P.epsUpper - d2 < P.epsUpper - d1 := by linarith
  have hProduct :
      P.q (P.jobDestructionTheta d2) * (P.epsUpper - d2) <
        P.q (P.jobDestructionTheta d1) * (P.epsUpper - d1) :=
    calc
      P.q (P.jobDestructionTheta d2) * (P.epsUpper - d2) <
          P.q (P.jobDestructionTheta d1) * (P.epsUpper - d2) :=
        mul_lt_mul_of_pos_right hq hgap2
      _ < P.q (P.jobDestructionTheta d1) * (P.epsUpper - d1) :=
        mul_lt_mul_of_pos_left hgap hq1
  have hScale := P.jobCreationScale_pos A
  unfold staticCrossingResidual
  nlinarith [mul_lt_mul_of_pos_right hProduct hScale]

theorem staticCrossingResidual_strictAntiOn
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    (M : MatchingAssumptions P) :
    StrictAntiOn P.staticCrossingResidual
      {d | P.IsAdmissibleStaticCutoff d} := by
  intro d1 h1 d2 h2 hd
  exact P.staticCrossingResidual_lt_of_lt A D M h1 h2 hd

end Primitives

/-- Figure 1: the job-destruction locus slopes upward. -/
theorem jobDestruction_curve_strictMono
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {theta1 theta2 d1 d2 : ℝ}
    (h1 : P.SatisfiesJobDestructionMeasure theta1 d1)
    (h2 : P.SatisfiesJobDestructionMeasure theta2 d2)
    (hd : d1 < d2) :
    theta1 < theta2 := by
  rw [(P.satisfiesJobDestructionMeasure_iff A theta1 d1).mp h1,
    (P.satisfiesJobDestructionMeasure_iff A theta2 d2).mp h2]
  exact P.jobDestructionTheta_strictMono A D hd

/-- Figure 1: among positive-tightness admissible pairs, the job-creation
locus slopes downward. -/
theorem jobCreation_curve_strictAnti
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (M : MatchingAssumptions P)
    {theta1 theta2 d1 d2 : ℝ}
    (htheta1 : 0 < theta1) (htheta2 : 0 < theta2)
    (hd1 : d1 < P.epsUpper) (hd2 : d2 < P.epsUpper)
    (hJC1 : P.SatisfiesJobCreationProduct theta1 d1)
    (hJC2 : P.SatisfiesJobCreationProduct theta2 d2)
    (hd : d1 < d2) :
    theta2 < theta1 := by
  by_contra hnot
  have hle : theta1 ≤ theta2 := le_of_not_gt hnot
  have hqle : P.q theta2 ≤ P.q theta1 := by
    rcases hle.eq_or_lt with hEq | hLt
    · simp [hEq]
    · exact (M.vacancyMeetingRate_strictAntiOn htheta1 htheta2 hLt).le
  have hq1 : 0 < P.q theta1 := M.vacancyMeetingRate_pos htheta1
  have hq2 : 0 < P.q theta2 := M.vacancyMeetingRate_pos htheta2
  have hgap1 : 0 < P.epsUpper - d1 := sub_pos.mpr hd1
  have hgap2 : 0 < P.epsUpper - d2 := sub_pos.mpr hd2
  have hgap : P.epsUpper - d2 < P.epsUpper - d1 := by linarith
  have hProduct :
      P.q theta2 * (P.epsUpper - d2) <
        P.q theta1 * (P.epsUpper - d1) :=
    calc
      P.q theta2 * (P.epsUpper - d2) ≤
          P.q theta1 * (P.epsUpper - d2) :=
        mul_le_mul_of_nonneg_right hqle hgap2.le
      _ < P.q theta1 * (P.epsUpper - d1) :=
        mul_lt_mul_of_pos_left hgap hq1
  have hScale := P.jobCreationScale_pos A
  unfold Primitives.SatisfiesJobCreationProduct at hJC1 hJC2
  unfold Primitives.jobCreationScale at hScale
  nlinarith [mul_lt_mul_of_pos_right hProduct hScale]

end MP1994V2
