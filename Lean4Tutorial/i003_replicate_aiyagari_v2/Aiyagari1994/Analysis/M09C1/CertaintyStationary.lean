import Aiyagari1994.Stationary.LowerTransition
import Aiyagari1994.Stationary.Kernel
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! Analytic implementation for A04: the mean-income deterministic household. -/
open MeasureTheory ProbabilityTheory Set Filter Function
open scoped ENNReal NNReal Topology ProbabilityTheory
namespace Aiyagari1994
noncomputable section

/-- Mean labor of the accepted compactly supported risky labor law. -/
def M09C1.meanLabor (m : HouseholdPrimitives) : ℝ :=
  ∫ l : m.income.Labor, (l : ℝ) ∂(m.income.law : Measure m.income.Labor)

private theorem M09C1.meanLabor_pos (m : HouseholdPrimitives) : 0 < M09C1.meanLabor m := by
  have hlower : m.income.lower ≤ M09C1.meanLabor m := by
    calc
      m.income.lower = ∫ _l : m.income.Labor, m.income.lower
          ∂(m.income.law : Measure m.income.Labor) := by simp
      _ ≤ ∫ l : m.income.Labor, (l : ℝ)
          ∂(m.income.law : Measure m.income.Labor) := by
        exact integral_mono (integrable_const _) (labor_integrable m.income)
          (fun l ↦ l.property.1)
  exact m.income_support.lower_pos.trans_le hlower

/-- A genuinely degenerate labor law, concentrated at the supplied positive mean labor. -/
def M09C1.certaintyIncome (meanLabor : ℝ) : IncomeData where
  lower := meanLabor
  upper := meanLabor
  law := ⟨Measure.dirac ⟨meanLabor, le_rfl, le_rfl⟩, by infer_instance⟩

private theorem M09C1.certaintyIncome_support (meanLabor : ℝ) (hmean : 0 < meanLabor) :
    IncomeSupport (M09C1.certaintyIncome meanLabor) :=
  ⟨hmean, le_rfl⟩

/-- The certainty household inherits preferences and discounting and puts all labor mass at the
actual mean of the supplied risky household.  Its prices carry their own certainty debt limit. -/
def M09C1.certaintyHousehold (base : HouseholdPrimitives)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base))) :
    HouseholdPrimitives where
  beta := base.beta
  beta_pos := base.beta_pos
  beta_lt_one := base.beta_lt_one
  utility := base.utility
  utility_base := base.utility_base
  income := M09C1.certaintyIncome (M09C1.meanLabor base)
  income_support := M09C1.certaintyIncome_support _ (M09C1.meanLabor_pos base)
  prices := p.normalized

/-- The point mass at a resource state, regarded as a probability measure. -/
def M09C1.pointMass (z : Resources) : ProbabilityMeasure Resources :=
  ⟨Measure.dirac z, by infer_instance⟩

/-- The deterministic law update.  A04 proves below that this is exactly the canonical household
kernel update for the certainty household. -/
def M09C1.certaintyLawStep (m : HouseholdPrimitives)
    (mu : ProbabilityMeasure Resources) : ProbabilityMeasure Resources :=
  mu.map (lowerTransition_continuous m).measurable.aemeasurable

private theorem M09C1.certainty_labor_eq
    (base : HouseholdPrimitives)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (l : (M09C1.certaintyHousehold base p).income.Labor) :
    l = ⟨M09C1.meanLabor base, le_rfl, le_rfl⟩ := by
  apply Subtype.ext
  exact le_antisymm l.property.2 l.property.1

private theorem M09C1.householdKernel_eq_transition_map
    (m : HouseholdPrimitives) (z : Resources) :
    householdKernel m z =
      (m.income.law : Measure m.income.Labor).map
        (fun l ↦ m.prices.nextResources (assetPolicy m z) l) := by
  ext s hs
  rw [householdKernel, Kernel.map_apply' _
    (householdTransition_continuous m).measurable _ hs,
    Kernel.id_prod_apply' _ _ ((householdTransition_continuous m).measurable hs),
    Kernel.const_apply]
  have hmeas : Measurable (fun l ↦ m.prices.nextResources (assetPolicy m z) l) :=
    ((householdTransition_continuous m).comp
      (continuous_const.prodMk continuous_id)).measurable
  rw [Measure.map_apply hmeas hs]
  rfl

private theorem M09C1.certainty_transition_eq_lower
    (base : HouseholdPrimitives)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (z : Resources) (l : (M09C1.certaintyHousehold base p).income.Labor) :
    (M09C1.certaintyHousehold base p).prices.nextResources
        (assetPolicy (M09C1.certaintyHousehold base p) z) l =
      lowerTransition (M09C1.certaintyHousehold base p) z := by
  rw [M09C1.certainty_labor_eq base p l]
  rfl

private theorem M09C1.certainty_kernel_eq_dirac
    (base : HouseholdPrimitives)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (z : Resources) :
    householdKernel (M09C1.certaintyHousehold base p) z =
      Measure.dirac (lowerTransition (M09C1.certaintyHousehold base p) z) := by
  rw [M09C1.householdKernel_eq_transition_map]
  change (Measure.dirac ⟨M09C1.meanLabor base, le_rfl, le_rfl⟩).map
      (fun l ↦ (M09C1.certaintyHousehold base p).prices.nextResources
        (assetPolicy (M09C1.certaintyHousehold base p) z) l) = _
  rw [Measure.map_dirac]
  exact congrArg Measure.dirac
    (M09C1.certainty_transition_eq_lower base p z _)

private theorem M09C1.certainty_lawStep_eq_kernel
    (base : HouseholdPrimitives)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (mu : ProbabilityMeasure Resources) :
    ((M09C1.certaintyLawStep (M09C1.certaintyHousehold base p) mu :
        ProbabilityMeasure Resources) : Measure Resources) =
      householdKernel (M09C1.certaintyHousehold base p) ∘ₘ
        (mu : Measure Resources) := by
  change (mu : Measure Resources).map
      (lowerTransition (M09C1.certaintyHousehold base p)) = _
  rw [← Measure.bind_dirac_eq_map _ (lowerTransition_continuous _).measurable]
  congr 1
  funext z
  exact (M09C1.certainty_kernel_eq_dirac base p z).symm

private theorem M09C1.iterate_succ_start {X : Type*} (f : X → X) (n : ℕ) (x : X) :
    f^[n + 1] x = f^[n] (f x) := by
  rw [Function.iterate_add_apply]
  rfl

private theorem M09C1.certainty_transition_iterates_tendsto
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) (z : Resources) :
    Tendsto (fun n : ℕ ↦
      (lowerTransition (M09C1.certaintyHousehold base p))^[n] z) atTop
      (nhds (lowerEffectiveIncome (M09C1.certaintyHousehold base p))) := by
  let m := M09C1.certaintyHousehold base p
  have hsmooth' : UtilitySmooth m.utility := hsmooth
  have hbetaR' : m.beta * m.prices.grossReturn < 1 := hbetaR
  have hcore := lower_transition_iterates_tendsto m hsmooth' hbetaR'
  by_cases hz : lowerEffectiveIncome m ≤ z
  · exact (hcore.2.2 z hz).2
  · have hnext : lowerEffectiveIncome m ≤ lowerTransition m z :=
      lowerEffectiveIncome_le_lowerTransition m z
    have htail := (hcore.2.2 (lowerTransition m z) hnext).2
    have hshift : Tendsto (fun n : ℕ ↦ (lowerTransition m)^[n + 1] z) atTop
        (nhds (lowerEffectiveIncome m)) := by
      simpa only [M09C1.iterate_succ_start] using htail
    exact (tendsto_add_atTop_iff_nat 1).1 hshift

private theorem M09C1.certainty_lawStep_iterate
    (m : HouseholdPrimitives) (mu : ProbabilityMeasure Resources) :
    ∀ n : ℕ, (M09C1.certaintyLawStep m)^[n] mu =
      mu.map ((lowerTransition_continuous m).iterate n).measurable.aemeasurable := by
  intro n
  induction n with
  | zero =>
      apply ProbabilityMeasure.toMeasure_injective
      simp
  | succ n ih =>
      rw [Function.iterate_succ_apply', ih]
      apply ProbabilityMeasure.toMeasure_injective
      simp only [M09C1.certaintyLawStep, ProbabilityMeasure.toMeasure_map]
      rw [Measure.map_map (lowerTransition_continuous m).measurable
        ((lowerTransition_continuous m).iterate n).measurable]
      congr 1
      funext z
      exact (Function.iterate_succ_apply' (lowerTransition m) n z).symm

private theorem M09C1.certainty_laws_tendsto
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1)
    (mu : ProbabilityMeasure Resources) :
    Tendsto (fun n : ℕ ↦
      (M09C1.certaintyLawStep (M09C1.certaintyHousehold base p))^[n] mu) atTop
      (nhds (M09C1.pointMass
        (lowerEffectiveIncome (M09C1.certaintyHousehold base p)))) := by
  let m := M09C1.certaintyHousehold base p
  let ebar := lowerEffectiveIncome m
  apply ProbabilityMeasure.tendsto_iff_forall_integral_tendsto.mpr
  intro f
  simp_rw [M09C1.certainty_lawStep_iterate]
  have hpoint : ∀ z : Resources,
      Tendsto (fun n : ℕ ↦ f ((lowerTransition m)^[n] z)) atTop (nhds (f ebar)) := by
    intro z
    exact f.continuous.continuousAt.tendsto.comp
      (M09C1.certainty_transition_iterates_tendsto base hsmooth p hbetaR z)
  have hdom := tendsto_integral_of_dominated_convergence
    (μ := (mu : Measure Resources)) (fun _ ↦ ‖f‖)
    (F := fun n z ↦ f ((lowerTransition m)^[n] z))
    (f := fun _ ↦ f ebar)
    (fun n ↦ (f.continuous.comp ((lowerTransition_continuous m).iterate n)).aestronglyMeasurable)
    (integrable_const ‖f‖)
    (fun n ↦ Filter.Eventually.of_forall fun z ↦ f.norm_coe_le_norm _)
    (Filter.Eventually.of_forall hpoint)
  simp only [ProbabilityMeasure.toMeasure_map]
  rw [show ∫ z, f z ∂(M09C1.pointMass ebar : Measure Resources) = f ebar by
    simp [M09C1.pointMass]]
  change Tendsto
    (fun n : ℕ ↦ ∫ z, f z
      ∂Measure.map ((lowerTransition m)^[n]) (mu : Measure Resources))
    atTop (nhds (f ebar))
  have hmap (n : ℕ) :
      (∫ z, f z ∂Measure.map ((lowerTransition m)^[n]) (mu : Measure Resources)) =
        ∫ z, f ((lowerTransition m)^[n] z) ∂(mu : Measure Resources) := by
    exact integral_map
      (((lowerTransition_continuous m).iterate n).measurable.aemeasurable)
      f.continuous.aestronglyMeasurable
  simp_rw [hmap]
  simpa [integral_const] using hdom

private theorem M09C1.iterate_fixed {X : Type*} (F : X → X) (x : X) (hx : F x = x) :
    ∀ n : ℕ, F^[n] x = x := by
  intro n
  induction n with
  | zero => rfl
  | succ n ih => rw [Function.iterate_succ_apply', ih, hx]

private theorem M09C1.certainty_pointMass_invariant
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) :
    householdKernel (M09C1.certaintyHousehold base p) ∘ₘ
        (M09C1.pointMass
          (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) : Measure Resources) =
      (M09C1.pointMass
        (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) : Measure Resources) := by
  let m := M09C1.certaintyHousehold base p
  let ebar := lowerEffectiveIncome m
  have hfix : lowerTransition m ebar = ebar :=
    (lower_transition_iterates_tendsto m hsmooth hbetaR).1
  rw [← M09C1.certainty_lawStep_eq_kernel base p]
  change (Measure.map (lowerTransition m) (Measure.dirac ebar)) = Measure.dirac ebar
  rw [Measure.map_dirac, hfix]

private theorem M09C1.certainty_invariant_unique
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1)
    (mu : ProbabilityMeasure Resources)
    (hinv : householdKernel (M09C1.certaintyHousehold base p) ∘ₘ
      (mu : Measure Resources) = (mu : Measure Resources)) :
    mu = M09C1.pointMass
      (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) := by
  let m := M09C1.certaintyHousehold base p
  let delta := M09C1.pointMass (lowerEffectiveIncome m)
  have hstep : M09C1.certaintyLawStep m mu = mu := by
    apply ProbabilityMeasure.toMeasure_injective
    rw [M09C1.certainty_lawStep_eq_kernel base p, hinv]
  have hconst : Tendsto (fun _ : ℕ ↦ mu) atTop (nhds mu) := tendsto_const_nhds
  have horbit : (fun n : ℕ ↦ (M09C1.certaintyLawStep m)^[n] mu) = fun _ ↦ mu := by
    funext n
    exact M09C1.iterate_fixed _ _ hstep n
  have hconv := M09C1.certainty_laws_tendsto base hsmooth p hbetaR mu
  rw [horbit] at hconv
  exact tendsto_nhds_unique hconst hconv

private theorem M09C1.certainty_assetPolicy_at_limit
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) :
    assetPolicy (M09C1.certaintyHousehold base p)
      (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) = 0 := by
  let m := M09C1.certaintyHousehold base p
  let ebar := lowerEffectiveIncome m
  have hfix : lowerTransition m ebar = ebar :=
    (lower_transition_iterates_tendsto m hsmooth hbetaR).1
  have hmul : m.prices.grossReturn *
      (assetPolicy m ebar : ℝ) = 0 := by
    have hcoe := congrArg ((↑·) : Resources → ℝ) hfix
    change m.prices.grossReturn * (assetPolicy m ebar : ℝ) +
      m.prices.effectiveIncome _ = m.prices.effectiveIncome _ at hcoe
    linarith
  have ha : (assetPolicy m ebar : ℝ) = 0 :=
    (mul_eq_zero.mp hmul).resolve_left (ne_of_gt m.prices.grossReturn_pos)
  exact NNReal.eq ha

private theorem M09C1.certainty_stationary_netAssets
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) :
    Integrable
        (fun z : Resources ↦
          ((assetPolicy (M09C1.certaintyHousehold base p) z : ℝ) - p.debtLimit))
        (M09C1.pointMass
          (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) : Measure Resources) ∧
      (∫ z : Resources,
          ((assetPolicy (M09C1.certaintyHousehold base p) z : ℝ) - p.debtLimit)
        ∂(M09C1.pointMass
          (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) : Measure Resources)) =
        -p.debtLimit := by
  constructor
  · apply integrable_dirac
    simp
  rw [show (M09C1.pointMass
      (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) : Measure Resources) =
      Measure.dirac (lowerEffectiveIncome (M09C1.certaintyHousehold base p)) by rfl]
  rw [integral_dirac]
  rw [M09C1.certainty_assetPolicy_at_limit base hsmooth p hbetaR]
  norm_num

/-- A04 analytic core.  The certainty household uses the risky law's actual mean labor and the
certainty `OriginalPrices.debtLimit`.  Its canonical resource update converges weakly from every
initial probability law to the unique invariant point mass, where shifted assets are zero and net
assets equal minus that certainty debt limit. -/
theorem M09C1_certainty_stationary_assets_at_limit
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (p : OriginalPrices (M09C1.certaintyIncome (M09C1.meanLabor base)))
    (hbetaR : base.beta * p.normalized.grossReturn < 1) :
    let m := M09C1.certaintyHousehold base p
    let ebar := lowerEffectiveIncome m
    let delta := M09C1.pointMass ebar
    (householdKernel m ∘ₘ (delta : Measure Resources) = (delta : Measure Resources)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      ((M09C1.certaintyLawStep m mu : ProbabilityMeasure Resources) : Measure Resources) =
        householdKernel m ∘ₘ (mu : Measure Resources)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      Tendsto (fun n : ℕ ↦ (M09C1.certaintyLawStep m)^[n] mu) atTop (nhds delta)) ∧
    (∀ mu : ProbabilityMeasure Resources,
      householdKernel m ∘ₘ (mu : Measure Resources) = (mu : Measure Resources) →
        mu = delta) ∧
    assetPolicy m ebar = 0 ∧
    Integrable (fun z : Resources ↦ ((assetPolicy m z : ℝ) - p.debtLimit))
      (delta : Measure Resources) ∧
    (∫ z : Resources, ((assetPolicy m z : ℝ) - p.debtLimit)
      ∂(delta : Measure Resources)) = -p.debtLimit := by
  dsimp only
  exact ⟨M09C1.certainty_pointMass_invariant base hsmooth p hbetaR,
    M09C1.certainty_lawStep_eq_kernel base p,
    M09C1.certainty_laws_tendsto base hsmooth p hbetaR,
    fun mu hinv ↦ M09C1.certainty_invariant_unique base hsmooth p hbetaR mu hinv,
    M09C1.certainty_assetPolicy_at_limit base hsmooth p hbetaR,
    (M09C1.certainty_stationary_netAssets base hsmooth p hbetaR).1,
    (M09C1.certainty_stationary_netAssets base hsmooth p hbetaR).2⟩

end
end Aiyagari1994
