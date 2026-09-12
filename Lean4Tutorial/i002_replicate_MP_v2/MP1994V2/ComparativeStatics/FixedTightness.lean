import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.SteadyState.StaticCurves
import Lean4Tutorial.i002_replicate_MP_v2.MP1994V2.ComparativeStatics.ParameterChanges

/-!
# MP1994 v2: cutoff effects at fixed market tightness

These results use the measure-form job-destruction condition only.
-/

namespace MP1994V2

theorem shockArrivalFraction_monotone
    {r lambdaLow lambdaHigh : ℝ}
    (hr : 0 < r) (hlow : 0 ≤ lambdaLow) (hord : lambdaLow ≤ lambdaHigh) :
    lambdaLow / (r + lambdaLow) ≤
      lambdaHigh / (r + lambdaHigh) := by
  have hhigh : 0 ≤ lambdaHigh := hlow.trans hord
  apply (div_le_div_iff₀ (add_pos_of_pos_of_nonneg hr hlow)
    (add_pos_of_pos_of_nonneg hr hhigh)).2
  nlinarith

theorem discountFraction_antitone
    {lambda rLow rHigh : ℝ}
    (hlambda : 0 ≤ lambda) (hrLow : 0 < rLow) (hord : rLow ≤ rHigh) :
    lambda / (rHigh + lambda) ≤ lambda / (rLow + lambda) := by
  have hrHigh : 0 < rHigh := lt_of_lt_of_le hrLow hord
  have hdenLow : 0 < rLow + lambda := add_pos_of_pos_of_nonneg hrLow hlambda
  have hdenHigh : 0 < rHigh + lambda := add_pos_of_pos_of_nonneg hrHigh hlambda
  apply (div_le_div_iff₀ hdenHigh hdenLow).2
  nlinarith

theorem cutoff_strictAnti_commonProductivity_at_fixed_theta
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {pLow pHigh theta dLow dHigh : ℝ}
    (hp : pLow < pHigh)
    (hLow : (P.withCommonProductivity pLow).SatisfiesJobDestructionMeasure theta dLow)
    (hHigh : (P.withCommonProductivity pHigh).SatisfiesJobDestructionMeasure theta dHigh) :
    dHigh < dLow := by
  let PH := P.withCommonProductivity pHigh
  have AH := A.withCommonProductivity pHigh
  have DH := D.withCommonProductivity pHigh
  have hNet : PH.jobDestructionNet dHigh < PH.jobDestructionNet dLow := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withCommonProductivity Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    linarith
  exact (PH.jobDestructionNet_strictMono AH DH).lt_iff_lt.mp hNet

theorem cutoff_strictMono_unemploymentIncome_at_fixed_theta
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {bLow bHigh theta dLow dHigh : ℝ}
    (hb : bLow < bHigh)
    (hLow : (P.withUnemploymentIncome bLow).SatisfiesJobDestructionMeasure theta dLow)
    (hHigh : (P.withUnemploymentIncome bHigh).SatisfiesJobDestructionMeasure theta dHigh) :
    dLow < dHigh := by
  let PH := P.withUnemploymentIncome bHigh
  have AH := A.withUnemploymentIncome bHigh
  have DH := D.withUnemploymentIncome bHigh
  have hNet : PH.jobDestructionNet dLow < PH.jobDestructionNet dHigh := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withUnemploymentIncome Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    linarith
  exact (PH.jobDestructionNet_strictMono AH DH).lt_iff_lt.mp hNet

theorem cutoff_antitone_shockArrival_at_fixed_theta
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {lambdaLow lambdaHigh theta dLow dHigh : ℝ}
    (hlow : 0 ≤ lambdaLow) (hlambda : lambdaLow < lambdaHigh)
    (hLow : (P.withShockArrivalRate lambdaLow).SatisfiesJobDestructionMeasure theta dLow)
    (hHigh : (P.withShockArrivalRate lambdaHigh).SatisfiesJobDestructionMeasure theta dHigh) :
    dHigh ≤ dLow := by
  let PH := P.withShockArrivalRate lambdaHigh
  have hhigh : 0 ≤ lambdaHigh := hlow.trans hlambda.le
  have AH := A.withShockArrivalRate lambdaHigh hhigh
  have DH := D.withShockArrivalRate lambdaHigh
  have hFrac := shockArrivalFraction_monotone A.r_pos hlow hlambda.le
  have hE := P.expectedExcess_nonneg dLow
  have hNet : PH.jobDestructionNet dHigh ≤ PH.jobDestructionNet dLow := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withShockArrivalRate Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    have hw := mul_le_mul_of_nonneg_right hFrac
      (mul_nonneg A.sigma_pos.le hE)
    have hw' :
        lambdaLow * P.sigma / (P.r + lambdaLow) * P.expectedExcess dLow ≤
          lambdaHigh * P.sigma / (P.r + lambdaHigh) * P.expectedExcess dLow := by
      calc
        lambdaLow * P.sigma / (P.r + lambdaLow) * P.expectedExcess dLow =
            (lambdaLow / (P.r + lambdaLow)) *
              (P.sigma * P.expectedExcess dLow) := by ring
        _ ≤ (lambdaHigh / (P.r + lambdaHigh)) *
              (P.sigma * P.expectedExcess dLow) := hw
        _ = lambdaHigh * P.sigma / (P.r + lambdaHigh) *
              P.expectedExcess dLow := by ring
    unfold Primitives.expectedExcess at hw'
    nlinarith [hw']
  exact (PH.jobDestructionNet_strictMono AH DH).le_iff_le.mp hNet

/-- If the option value at the low-arrival cutoff is positive, a higher shock
arrival rate strictly lowers the destruction cutoff at fixed tightness. -/
theorem cutoff_strictAnti_shockArrival_at_fixed_theta_of_expectedExcess_pos
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {lambdaLow lambdaHigh theta dLow dHigh : ℝ}
    (hlow : 0 ≤ lambdaLow) (hlambda : lambdaLow < lambdaHigh)
    (hLow : Primitives.SatisfiesJobDestructionMeasure
      (P.withShockArrivalRate lambdaLow) theta dLow)
    (hHigh : Primitives.SatisfiesJobDestructionMeasure
      (P.withShockArrivalRate lambdaHigh) theta dHigh)
    (hOption : 0 < P.expectedExcess dLow) :
    dHigh < dLow := by
  let PH := P.withShockArrivalRate lambdaHigh
  have hhigh : 0 ≤ lambdaHigh := hlow.trans hlambda.le
  have AH := A.withShockArrivalRate lambdaHigh hhigh
  have DH := D.withShockArrivalRate lambdaHigh
  have hdenLow : 0 < P.r + lambdaLow :=
    add_pos_of_pos_of_nonneg A.r_pos hlow
  have hdenHigh : 0 < P.r + lambdaHigh :=
    add_pos_of_pos_of_nonneg A.r_pos hhigh
  have hFrac : lambdaLow / (P.r + lambdaLow) <
      lambdaHigh / (P.r + lambdaHigh) := by
    apply (div_lt_div_iff₀ hdenLow hdenHigh).2
    have hmul := mul_lt_mul_of_pos_right hlambda A.r_pos
    calc
      lambdaLow * (P.r + lambdaHigh) =
          lambdaLow * P.r + lambdaLow * lambdaHigh := by ring
      _ < lambdaHigh * P.r + lambdaLow * lambdaHigh :=
        by simpa [add_comm] using
          (add_lt_add_right hmul (lambdaLow * lambdaHigh))
      _ = lambdaHigh * (P.r + lambdaLow) := by ring
  have hWeighted :
      lambdaLow * P.sigma / (P.r + lambdaLow) * P.expectedExcess dLow <
        lambdaHigh * P.sigma / (P.r + lambdaHigh) *
          P.expectedExcess dLow := by
    calc
      lambdaLow * P.sigma / (P.r + lambdaLow) * P.expectedExcess dLow =
          (lambdaLow / (P.r + lambdaLow)) *
            (P.sigma * P.expectedExcess dLow) := by ring
      _ < (lambdaHigh / (P.r + lambdaHigh)) *
            (P.sigma * P.expectedExcess dLow) :=
        mul_lt_mul_of_pos_right hFrac (mul_pos A.sigma_pos hOption)
      _ = lambdaHigh * P.sigma / (P.r + lambdaHigh) *
            P.expectedExcess dLow := by ring
  have hNet : PH.jobDestructionNet dHigh <
      PH.jobDestructionNet dLow := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withShockArrivalRate Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    nlinarith [hWeighted]
  exact (PH.jobDestructionNet_strictMono AH DH).lt_iff_lt.mp hNet

theorem cutoff_monotone_discountRate_at_fixed_theta
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {rLow rHigh theta dLow dHigh : ℝ}
    (hrLow : 0 < rLow) (hr : rLow < rHigh)
    (hLow : (P.withDiscountRate rLow).SatisfiesJobDestructionMeasure theta dLow)
    (hHigh : (P.withDiscountRate rHigh).SatisfiesJobDestructionMeasure theta dHigh) :
    dLow ≤ dHigh := by
  let PH := P.withDiscountRate rHigh
  have AH := A.withDiscountRate rHigh (hrLow.trans hr)
  have DH := D.withDiscountRate rHigh
  have hFrac := discountFraction_antitone A.lambda_nonneg hrLow hr.le
  have hE := P.expectedExcess_nonneg dLow
  have hNet : PH.jobDestructionNet dLow ≤ PH.jobDestructionNet dHigh := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withDiscountRate Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    have hw := mul_le_mul_of_nonneg_right hFrac
      (mul_nonneg A.sigma_pos.le hE)
    have hw' :
        P.lambda * P.sigma / (rHigh + P.lambda) * P.expectedExcess dLow ≤
          P.lambda * P.sigma / (rLow + P.lambda) * P.expectedExcess dLow := by
      calc
        P.lambda * P.sigma / (rHigh + P.lambda) * P.expectedExcess dLow =
            (P.lambda / (rHigh + P.lambda)) *
              (P.sigma * P.expectedExcess dLow) := by ring
        _ ≤ (P.lambda / (rLow + P.lambda)) *
              (P.sigma * P.expectedExcess dLow) := hw
        _ = P.lambda * P.sigma / (rLow + P.lambda) *
              P.expectedExcess dLow := by ring
    unfold Primitives.expectedExcess at hw'
    nlinarith [hw']
  exact (PH.jobDestructionNet_strictMono AH DH).le_iff_le.mp hNet

/-- With positive redraw intensity and positive option value at the low-rate
cutoff, a higher discount rate strictly raises the destruction cutoff at fixed
tightness. -/
theorem cutoff_strictMono_discountRate_at_fixed_theta_of_optionValue_pos
    {P : Primitives}
    (A : CoreEconomicAssumptions P)
    (D : ShockAssumptions P)
    {rLow rHigh theta dLow dHigh : ℝ}
    (hrLow : 0 < rLow) (hr : rLow < rHigh)
    (hlambda : 0 < P.lambda)
    (hLow : Primitives.SatisfiesJobDestructionMeasure
      (P.withDiscountRate rLow) theta dLow)
    (hHigh : Primitives.SatisfiesJobDestructionMeasure
      (P.withDiscountRate rHigh) theta dHigh)
    (hOption : 0 < P.expectedExcess dLow) :
    dLow < dHigh := by
  let PH := P.withDiscountRate rHigh
  have AH := A.withDiscountRate rHigh (hrLow.trans hr)
  have DH := D.withDiscountRate rHigh
  have hdenLow : 0 < rLow + P.lambda :=
    add_pos_of_pos_of_nonneg hrLow A.lambda_nonneg
  have hdenHigh : 0 < rHigh + P.lambda :=
    add_pos_of_pos_of_nonneg (hrLow.trans hr) A.lambda_nonneg
  have hFrac : P.lambda / (rHigh + P.lambda) <
      P.lambda / (rLow + P.lambda) := by
    apply (div_lt_div_iff₀ hdenHigh hdenLow).2
    have hmul := mul_lt_mul_of_pos_left hr hlambda
    calc
      P.lambda * (rLow + P.lambda) =
          P.lambda * rLow + P.lambda * P.lambda := by ring
      _ < P.lambda * rHigh + P.lambda * P.lambda :=
        by simpa [add_comm] using
          (add_lt_add_right hmul (P.lambda * P.lambda))
      _ = P.lambda * (rHigh + P.lambda) := by ring
  have hWeighted :
      P.lambda * P.sigma / (rHigh + P.lambda) * P.expectedExcess dLow <
        P.lambda * P.sigma / (rLow + P.lambda) *
          P.expectedExcess dLow := by
    calc
      P.lambda * P.sigma / (rHigh + P.lambda) * P.expectedExcess dLow =
          (P.lambda / (rHigh + P.lambda)) *
            (P.sigma * P.expectedExcess dLow) := by ring
      _ < (P.lambda / (rLow + P.lambda)) *
            (P.sigma * P.expectedExcess dLow) :=
        mul_lt_mul_of_pos_right hFrac (mul_pos A.sigma_pos hOption)
      _ = P.lambda * P.sigma / (rLow + P.lambda) *
            P.expectedExcess dLow := by ring
  have hNet : PH.jobDestructionNet dLow <
      PH.jobDestructionNet dHigh := by
    unfold Primitives.SatisfiesJobDestructionMeasure
      Primitives.jobDestructionResidualMeasure at hLow hHigh
    unfold PH Primitives.withDiscountRate Primitives.jobDestructionNet
      Primitives.expectedExcess at *
    simp only at hLow hHigh ⊢
    nlinarith [hWeighted]
  exact (PH.jobDestructionNet_strictMono AH DH).lt_iff_lt.mp hNet

end MP1994V2
