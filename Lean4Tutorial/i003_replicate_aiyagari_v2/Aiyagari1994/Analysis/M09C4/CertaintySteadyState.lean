import Aiyagari1994.Firms.Neoclassical
import Aiyagari1994.Household.Verification

/-! Analytic implementation for G05: the mean-one certainty steady state. -/
open MeasureTheory Set Filter Finset
open scoped NNReal Topology
namespace Aiyagari1994
noncomputable section

namespace M09C4

/-- The degenerate mean-one labor law used only by the G05 certainty benchmark. -/
def certaintyIncomeOne : IncomeData where
  lower := 1
  upper := 1
  law := ⟨Measure.dirac ⟨1, le_rfl, le_rfl⟩, by infer_instance⟩

end M09C4

private abbrev certaintyIncomeOne := M09C4.certaintyIncomeOne

private theorem certaintyIncomeOne_support : IncomeSupport certaintyIncomeOne := by
  refine ⟨?_, le_rfl⟩
  change (0 : ℝ) < 1
  norm_num

private def certaintyLaborOne : certaintyIncomeOne.Labor := ⟨1, le_rfl, le_rfl⟩

private theorem certaintyLaborOne_eq (l : certaintyIncomeOne.Labor) : l = certaintyLaborOne := by
  apply Subtype.ext
  exact le_antisymm l.property.2 l.property.1

private def certaintyPrices (lambda wage phi : ℝ) (hlambda : -1 < lambda)
    (hwage : 0 < wage) (hphi : 0 ≤ phi) (hincome : lambda * phi ≤ wage) :
    OriginalPrices certaintyIncomeOne where
  netRate := lambda
  wage := wage
  debtLimit := phi
  netRate_gt := hlambda
  wage_pos := hwage
  debtLimit_nonneg := hphi
  income_nonneg := by
    intro l
    rw [certaintyLaborOne_eq l]
    change 0 ≤ wage * 1 - lambda * phi
    linarith

private def certaintyHousehold (base : HouseholdPrimitives) (lambda wage phi : ℝ)
    (hlambda : -1 < lambda) (hwage : 0 < wage) (hphi : 0 ≤ phi)
    (hincome : lambda * phi ≤ wage) : HouseholdPrimitives where
  beta := base.beta
  beta_pos := base.beta_pos
  beta_lt_one := base.beta_lt_one
  utility := base.utility
  utility_base := base.utility_base
  income := certaintyIncomeOne
  income_support := certaintyIncomeOne_support
  prices := (certaintyPrices lambda wage phi hlambda hwage hphi hincome).normalized

private def benchmarkHistory (m : HouseholdPrimitives) (lone : m.income.Labor)
    (t : ℕ) : History m t := fun _ ↦ lone

private theorem certainty_history_unique (m : HouseholdPrimitives)
    (lone : m.income.Labor) (hlabor : ∀ l : m.income.Labor, l = lone)
    (t : ℕ) (h : History m t) : h = benchmarkHistory m lone t := by
  funext j
  exact hlabor (h j)

private theorem utility_supporting_line (base : HouseholdPrimitives)
    (hsmooth : UtilitySmooth base.utility) {cstar c : ℝ} (hcstar : 0 < cstar) (hc : 0 ≤ c) :
    base.utility.utility c - base.utility.utility cstar ≤
      deriv base.utility.utility cstar * (c - cstar) := by
  have hd : DifferentiableAt ℝ base.utility.utility cstar :=
    (hsmooth.smooth.differentiableOn_one cstar hcstar).differentiableAt
      (isOpen_Ioi.mem_nhds hcstar)
  rcases lt_trichotomy c cstar with hlt | rfl | hgt
  · have hs := base.utility_base.concave.concaveOn.deriv_le_slope
      (x := c) (y := cstar) hc hcstar.le hlt hd
    simp only [slope, vsub_eq_sub, smul_eq_mul] at hs
    rw [inv_mul_eq_div] at hs
    have hden : 0 < cstar - c := sub_pos.mpr hlt
    have := (le_div_iff₀ hden).mp hs
    nlinarith
  · simp
  · have hs := base.utility_base.concave.concaveOn.slope_le_deriv
      (x := cstar) (y := c) hcstar.le hc hgt hd
    simp only [slope, vsub_eq_sub, smul_eq_mul] at hs
    rw [inv_mul_eq_div] at hs
    have hden : 0 < c - cstar := sub_pos.mpr hgt
    exact (div_le_iff₀ hden).mp hs

private def constantBenchmarkPlan (m : HouseholdPrimitives) (zstar astar : Resources)
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hfeasible : astar ≤ zstar) : FeasiblePlan m zstar where
  action := fun _ _ ↦ astar
  measurable_action := fun _ ↦ measurable_const
  feasible := by
    intro t h
    cases t with
    | zero => exact hfeasible
    | succ t =>
        change astar ≤ m.prices.nextResources astar (newestShock m t h)
        rw [hfixed]
        exact hfeasible

private theorem constantBenchmarkPlan_resources (m : HouseholdPrimitives) (zstar astar : Resources)
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hfeasible : astar ≤ zstar) (t : ℕ) (h : History m t) :
    planResources (constantBenchmarkPlan m zstar astar hfixed hfeasible) t h = zstar := by
  cases t with
  | zero => rfl
  | succ t => exact hfixed _

private theorem constantBenchmarkPlan_consumption (m : HouseholdPrimitives)
    (zstar astar cstar : Resources)
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hfeasible : astar ≤ zstar) (hbudget : zstar = cstar + astar)
    (t : ℕ) (h : History m t) :
    planConsumption (constantBenchmarkPlan m zstar astar hfixed hfeasible) t h = cstar := by
  apply NNReal.eq
  rw [planConsumption_coe, constantBenchmarkPlan_resources]
  change (zstar : ℝ) - (astar : ℝ) = (cstar : ℝ)
  rw [hbudget]
  simp

private theorem expectedFlow_eq_path (m : HouseholdPrimitives)
    (lone : m.income.Labor) (hlabor : ∀ l : m.income.Labor, l = lone)
    {z0 : Resources} (q : FeasiblePlan m z0) (t : ℕ) :
    expectedFlow q t = flowUtility q t (benchmarkHistory m lone t) := by
  rw [expectedFlow]
  have heq : flowUtility q t = fun _ ↦ flowUtility q t (benchmarkHistory m lone t) := by
    funext h
    rw [certainty_history_unique m lone hlabor t h]
  rw [heq]
  simp

private theorem benchmarkPlan_lifetimeUtility (m : HouseholdPrimitives)
    (zstar astar cstar : Resources)
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hfeasible : astar ≤ zstar) (hbudget : zstar = cstar + astar) :
    lifetimeUtility (constantBenchmarkPlan m zstar astar hfixed hfeasible) =
      m.utility.utility cstar / (1 - m.beta) := by
  unfold lifetimeUtility
  have hflow (t : ℕ) :
      expectedFlow (constantBenchmarkPlan m zstar astar hfixed hfeasible) t =
        m.utility.utility cstar := by
    rw [expectedFlow]
    have heq : flowUtility (constantBenchmarkPlan m zstar astar hfixed hfeasible) t =
        fun _ ↦ m.utility.utility cstar := by
      funext h
      simp only [flowUtility]
      rw [constantBenchmarkPlan_consumption m zstar astar cstar hfixed hfeasible hbudget]
    rw [heq]
    simp
  simp_rw [hflow]
  rw [tsum_mul_right]
  rw [tsum_geometric_of_lt_one m.beta_pos.le m.beta_lt_one]
  field_simp

private theorem finite_present_value_budget
    (m : HouseholdPrimitives) (lone : m.income.Labor)
    (hlabor : ∀ l : m.income.Labor, l = lone)
    (hbetaR : m.beta * m.prices.grossReturn = 1)
    (zstar astar cstar : Resources)
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hbudget : zstar = cstar + astar)
    (q : FeasiblePlan m zstar) : ∀ N : ℕ,
      ∑ t ∈ range (N + 1), m.beta ^ t *
        ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar) =
          m.beta ^ N *
            ((astar : ℝ) - (q.action N (benchmarkHistory m lone N) : ℝ)) := by
  intro N
  induction N with
  | zero =>
      simp only [zero_add, sum_range_one, pow_zero, one_mul]
      rw [planConsumption_coe]
      change (zstar : ℝ) - (q.action 0 (benchmarkHistory m lone 0) : ℝ) - cstar = _
      have hz := congrArg (↑· : Resources → ℝ) hbudget
      simp only [NNReal.coe_add] at hz
      rw [hz]
      ring
  | succ N ih =>
      rw [sum_range_succ, ih]
      have hc := planConsumption_coe q (N + 1) (benchmarkHistory m lone (N + 1))
      have hprev : previousHistory m N (benchmarkHistory m lone (N + 1)) =
          benchmarkHistory m lone N :=
        certainty_history_unique m lone hlabor N _
      have hnew : newestShock m N (benchmarkHistory m lone (N + 1)) = lone :=
        hlabor _
      have hres : (planResources q (N + 1) (benchmarkHistory m lone (N + 1)) : ℝ) =
          m.prices.grossReturn *
              (q.action N (benchmarkHistory m lone N) : ℝ) +
            m.prices.effectiveIncome lone := by
        change ((m.prices.nextResources
          (q.action N (previousHistory m N (benchmarkHistory m lone (N + 1))))
          (newestShock m N (benchmarkHistory m lone (N + 1))) : Resources) : ℝ) = _
        rw [hprev, hnew]
        rfl
      have hstation : (cstar : ℝ) + astar =
          m.prices.grossReturn * astar + m.prices.effectiveIncome lone := by
        have hf := congrArg (↑· : Resources → ℝ) (hfixed lone)
        change m.prices.grossReturn * (astar : ℝ) + m.prices.effectiveIncome lone =
          (zstar : ℝ) at hf
        have hz := congrArg (↑· : Resources → ℝ) hbudget
        simp only [NNReal.coe_add] at hz
        linarith
      rw [hc, hres]
      have heff : m.prices.effectiveIncome lone =
          (cstar : ℝ) + astar - m.prices.grossReturn * astar := by
        linarith [hstation]
      rw [heff]
      have hpowrel : m.beta ^ (N + 1) * m.prices.grossReturn = m.beta ^ N := by
        calc
          _ = m.beta ^ N * (m.beta * m.prices.grossReturn) := by rw [pow_succ]; ring
          _ = _ := by rw [hbetaR, mul_one]
      calc
        _ = m.beta ^ N *
              ((astar : ℝ) - (q.action N (benchmarkHistory m lone N) : ℝ)) +
            (m.beta ^ (N + 1) * m.prices.grossReturn) *
              ((q.action N (benchmarkHistory m lone N) : ℝ) - astar) +
            m.beta ^ (N + 1) *
              ((astar : ℝ) -
                (q.action (N + 1) (benchmarkHistory m lone (N + 1)) : ℝ)) := by ring
        _ = _ := by rw [hpowrel]; ring

/-- Global optimality is proved from the finite present-value budget and the utility supporting
line.  The vanishing terminal upper bound uses only nonnegative shifted saving and `beta < 1`;
it is not a primitive transversality or No-Ponzi assumption. -/
private theorem constantBenchmarkPlan_lifetime_optimal
    (m : HouseholdPrimitives) (hsmooth : UtilitySmooth m.utility)
    (lone : m.income.Labor) (hlabor : ∀ l : m.income.Labor, l = lone)
    (hbetaR : m.beta * m.prices.grossReturn = 1)
    (zstar astar cstar : Resources) (hcstar : 0 < (cstar : ℝ))
    (hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar)
    (hfeasible : astar ≤ zstar) (hbudget : zstar = cstar + astar) :
    ∀ q : FeasiblePlan m zstar,
      lifetimeUtility q ≤
        lifetimeUtility (constantBenchmarkPlan m zstar astar hfixed hfeasible) := by
  intro q
  let bp := constantBenchmarkPlan m zstar astar hfixed hfeasible
  have hflowbp (t : ℕ) : expectedFlow bp t = m.utility.utility cstar := by
    rw [expectedFlow]
    have heq : flowUtility bp t = fun _ ↦ m.utility.utility cstar := by
      funext h
      simp only [flowUtility, bp]
      rw [constantBenchmarkPlan_consumption m zstar astar cstar hfixed hfeasible hbudget]
    rw [heq]
    simp
  have hfinite (N : ℕ) :
      finiteUtility q (N + 1) - finiteUtility bp (N + 1) ≤
        deriv m.utility.utility cstar * (m.beta ^ N * astar) := by
    have hpv := finite_present_value_budget m lone hlabor hbetaR zstar astar cstar
      hfixed hbudget q N
    have hpv_le :
        ∑ t ∈ range (N + 1), m.beta ^ t *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar) ≤
          m.beta ^ N * astar := by
      rw [hpv]
      exact mul_le_mul_of_nonneg_left
        (sub_le_self _ (q.action N (benchmarkHistory m lone N)).property)
        (pow_nonneg m.beta_pos.le N)
    have hterm (t : ℕ) :
        m.beta ^ t * (expectedFlow q t - expectedFlow bp t) ≤
          m.beta ^ t * deriv m.utility.utility cstar *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar) := by
      rw [expectedFlow_eq_path m lone hlabor q t, hflowbp]
      change m.beta ^ t *
          (m.utility.utility (planConsumption q t (benchmarkHistory m lone t) : ℝ) -
            m.utility.utility cstar) ≤ _
      have hsupp := utility_supporting_line m hsmooth hcstar
        (show 0 ≤ (planConsumption q t (benchmarkHistory m lone t) : ℝ) from
          (planConsumption q t (benchmarkHistory m lone t)).property)
      calc
        _ ≤ m.beta ^ t * (deriv m.utility.utility cstar *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar)) :=
          mul_le_mul_of_nonneg_left hsupp (pow_nonneg m.beta_pos.le t)
        _ = _ := by ring
    have hsum :
        (∑ t ∈ range (N + 1), m.beta ^ t * (expectedFlow q t - expectedFlow bp t)) ≤
          ∑ t ∈ range (N + 1), m.beta ^ t * deriv m.utility.utility cstar *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar) :=
      sum_le_sum fun t _ ↦ hterm t
    have hderiv : 0 ≤ deriv m.utility.utility cstar :=
      (hsmooth.marginal_pos cstar hcstar).le
    simp_rw [hflowbp] at hsum
    unfold finiteUtility
    simp_rw [hflowbp]
    calc
      _ = ∑ t ∈ range (N + 1),
          (m.beta ^ t * expectedFlow q t -
            m.beta ^ t * m.utility.utility cstar) := by
        exact (sum_sub_distrib (s := range (N + 1))
          (fun t ↦ m.beta ^ t * expectedFlow q t)
          (fun t ↦ m.beta ^ t * m.utility.utility cstar)).symm
      _ = ∑ t ∈ range (N + 1),
          m.beta ^ t * (expectedFlow q t - m.utility.utility cstar) := by
        apply sum_congr rfl
        intro t ht
        ring
      _ ≤ ∑ t ∈ range (N + 1),
          m.beta ^ t * deriv m.utility.utility cstar *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar) := hsum
      _ = deriv m.utility.utility cstar *
          (∑ t ∈ range (N + 1), m.beta ^ t *
            ((planConsumption q t (benchmarkHistory m lone t) : ℝ) - cstar)) := by
        rw [mul_sum]
        apply sum_congr rfl
        intro t ht
        ring
      _ ≤ deriv m.utility.utility cstar * (m.beta ^ N * astar) :=
        mul_le_mul_of_nonneg_left hpv_le hderiv
  have htq : Tendsto (fun N ↦ finiteUtility q (N + 1)) atTop
      (nhds (lifetimeUtility q)) :=
    (tendsto_add_atTop_iff_nat 1).2 (finiteUtility_tendsto q)
  have htbp : Tendsto (fun N ↦ finiteUtility bp (N + 1)) atTop
      (nhds (lifetimeUtility bp)) :=
    (tendsto_add_atTop_iff_nat 1).2 (finiteUtility_tendsto bp)
  have hlhs : Tendsto (fun N ↦ finiteUtility q (N + 1) - finiteUtility bp (N + 1))
      atTop (nhds (lifetimeUtility q - lifetimeUtility bp)) := htq.sub htbp
  have hrhs : Tendsto
      (fun N ↦ deriv m.utility.utility cstar * (m.beta ^ N * (astar : ℝ)))
      atTop (nhds 0) := by
    convert (tendsto_pow_atTop_nhds_zero_of_lt_one m.beta_pos.le m.beta_lt_one).const_mul
      (deriv m.utility.utility cstar * astar) using 1 <;> ring_nf
  have hle : lifetimeUtility q - lifetimeUtility bp ≤ 0 :=
    le_of_tendsto_of_tendsto hlhs hrhs (Eventually.of_forall hfinite)
  linarith

/-- The exact G05 proposition implemented by the gate-local proof and exported by the public
wrapper. -/
def M09C4.CertaintyBenchmarkStatement
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (hmean : LaborMeanOne base.income) (prod : ProductionData)
    (hprod : ProductionRegularity prod) : Prop :=
    let lambda := 1 / base.beta - 1
    ∃ rFI : FirmRate prod,
      (rFI : ℝ) = lambda ∧
      -prod.depreciation < lambda ∧
      let K := capitalDemand prod hprod rFI
      let wage := firmWage prod hprod rFI
      let cFI := prod.output K - prod.depreciation * K
      0 < K ∧
      0 < wage ∧
      deriv prod.output K = lambda + prod.depreciation ∧
      cFI = wage + lambda * K ∧
      0 < cFI ∧
      (∫ l : base.income.Labor, (l : ℝ) ∂(base.income.law : Measure base.income.Labor)) = 1 ∧
      (∀ b : ℝ, 0 ≤ b →
        0 ≤ min b (wage / lambda) ∧ lambda * min b (wage / lambda) ≤ wage) ∧
      0 ≤ wage / lambda ∧
      lambda * (wage / lambda) = wage ∧
      ∀ phi : ℝ, 0 ≤ phi → lambda * phi ≤ wage →
        ∃ (prices : OriginalPrices M09C4.certaintyIncomeOne)
          (m : HouseholdPrimitives) (zstar astar cstar : Resources)
          (bp : FeasiblePlan m zstar),
          prices.netRate = lambda ∧
          prices.wage = wage ∧
          prices.debtLimit = phi ∧
          m.beta = base.beta ∧
          m.utility = base.utility ∧
          m.income = M09C4.certaintyIncomeOne ∧
          HEq m.prices prices.normalized ∧
          (astar : ℝ) = K + phi ∧
          (cstar : ℝ) = cFI ∧
          zstar = cstar + astar ∧
          m.beta * m.prices.grossReturn = 1 ∧
          (K : ℝ) = (astar : ℝ) - phi ∧
          -phi ≤ K ∧
          (∀ t h, bp.action t h = astar ∧ planResources bp t h = zstar ∧
            planConsumption bp t h = cstar) ∧
          (∀ h : History m 0,
            (planConsumption bp 0 h : ℝ) + ((bp.action 0 h : ℝ) - phi) =
                (1 + lambda) * K + wage * 1 ∧
              -phi ≤ (bp.action 0 h : ℝ) - phi) ∧
          lifetimeUtility bp = valueFunction m zstar ∧
          ∀ q : FeasiblePlan m zstar, lifetimeUtility q ≤ lifetimeUtility bp

/-- G05 core.  At `lambda = 1 / beta - 1`, F01 constructs positive capital and wages.
For every nonnegative certainty debt shift whose mean-one effective income is nonnegative, the
constant capital/consumption allocation is feasible and globally lifetime-optimal against every
admitted measurable full-history plan. -/
theorem M09C4_certainty_benchmark_verified_core
    (base : HouseholdPrimitives) (hsmooth : UtilitySmooth base.utility)
    (hmean : LaborMeanOne base.income) (prod : ProductionData)
    (hprod : ProductionRegularity prod) :
    M09C4.CertaintyBenchmarkStatement base hsmooth hmean prod hprod := by
  unfold M09C4.CertaintyBenchmarkStatement
  dsimp only
  let lambda : ℝ := 1 / base.beta - 1
  have hlambda_pos : 0 < lambda := by
    dsimp [lambda]
    apply sub_pos.mpr
    apply (lt_div_iff₀ base.beta_pos).mpr
    simpa only [one_mul] using base.beta_lt_one
  have hlambda_rate : -prod.depreciation < lambda := by
    linarith [hprod.depreciation_positive]
  let rFI : FirmRate prod := ⟨lambda, hlambda_rate⟩
  refine ⟨rFI, rfl, hlambda_rate, ?_⟩
  let K := capitalDemand prod hprod rFI
  let wage := firmWage prod hprod rFI
  let cFI := prod.output K - prod.depreciation * K
  have hfirm := (capitalDemand_wage_constructed prod hprod).1 rFI
  have hK : 0 < K := capitalDemand_positive prod hprod rFI
  have hwage : 0 < wage := hfirm.2.1
  have hmarginal : deriv prod.output K = lambda + prod.depreciation := by
    simpa [K, rFI] using hfirm.1
  have hcidentity : cFI = wage + lambda * K := by
    dsimp [cFI, wage, firmWage]
    rw [hmarginal]
    ring
  have hcpos : 0 < cFI := by
    rw [hcidentity]
    positivity
  have hfinite : ∀ b : ℝ, 0 ≤ b →
      0 ≤ min b (wage / lambda) ∧ lambda * min b (wage / lambda) ≤ wage := by
    intro b hb
    refine ⟨le_min hb (div_nonneg hwage.le hlambda_pos.le), ?_⟩
    have hmin : min b (wage / lambda) ≤ wage / lambda := min_le_right _ _
    simpa only [mul_comm] using (le_div_iff₀ hlambda_pos).mp hmin
  have hnatural_nonneg : 0 ≤ wage / lambda := div_nonneg hwage.le hlambda_pos.le
  have hnatural_income : lambda * (wage / lambda) = wage := by
    field_simp [ne_of_gt hlambda_pos]
  refine ⟨hK, hwage, hmarginal, hcidentity, hcpos, hmean.mean_eq_one,
    hfinite, hnatural_nonneg, hnatural_income, ?_⟩
  intro phi hphi hincome
  have hlambda_gt : -1 < lambda := by linarith
  let prices := certaintyPrices lambda wage phi hlambda_gt hwage hphi hincome
  let m := certaintyHousehold base lambda wage phi hlambda_gt hwage hphi hincome
  have hA : 0 ≤ K + phi := add_nonneg hK.le hphi
  let astar : Resources := ⟨K + phi, hA⟩
  let cstar : Resources := ⟨cFI, hcpos.le⟩
  let zstar : Resources := cstar + astar
  have hlabor : ∀ l : m.income.Labor, l = certaintyLaborOne := by
    intro l
    exact certaintyLaborOne_eq l
  have hfixed : ∀ l : m.income.Labor, m.prices.nextResources astar l = zstar := by
    intro l
    rw [hlabor l]
    apply NNReal.eq
    change (1 + lambda) * (K + phi) + (wage * 1 + -lambda * phi) =
      cFI + (K + phi)
    rw [hcidentity]
    ring
  have hfeasible : astar ≤ zstar := by
    dsimp [zstar]
    exact le_add_of_nonneg_left cstar.property
  let bp := constantBenchmarkPlan m zstar astar hfixed hfeasible
  have hbetaR : m.beta * m.prices.grossReturn = 1 := by
    change base.beta * (1 + lambda) = 1
    dsimp [lambda]
    field_simp [ne_of_gt base.beta_pos]
    ring
  have hdirect : ∀ q : FeasiblePlan m zstar, lifetimeUtility q ≤ lifetimeUtility bp := by
    exact constantBenchmarkPlan_lifetime_optimal m hsmooth certaintyLaborOne hlabor hbetaR
      zstar astar cstar hcpos hfixed hfeasible rfl
  have hcanonical := canonicalPolicy_lifetime_optimal m zstar
  have hbp_value : lifetimeUtility bp = valueFunction m zstar := by
    have hcan_le := hdirect (canonicalPlan m zstar)
    have hbp_le := hcanonical.2.2.2 bp
    have hbp_le_value : lifetimeUtility bp ≤ valueFunction m zstar :=
      hbp_le.trans_eq hcanonical.2.2.1
    have hvalue_le : valueFunction m zstar ≤ lifetimeUtility bp := by
      rw [← hcanonical.2.2.1]
      exact hcan_le
    exact le_antisymm hbp_le_value hvalue_le
  have hpath : ∀ t h, bp.action t h = astar ∧ planResources bp t h = zstar ∧
      planConsumption bp t h = cstar := by
    intro t h
    refine ⟨rfl, constantBenchmarkPlan_resources m zstar astar hfixed hfeasible t h, ?_⟩
    exact constantBenchmarkPlan_consumption m zstar astar cstar hfixed hfeasible rfl t h
  have hz_original : (zstar : ℝ) =
      (1 + prices.netRate) * (K + prices.debtLimit) +
        prices.wage * (certaintyLaborOne : ℝ) - prices.netRate * prices.debtLimit := by
    change cFI + (K + phi) = (1 + lambda) * (K + phi) + wage * 1 - lambda * phi
    rw [hcidentity]
    ring
  have hinitial : ∀ h : History m 0,
      (planConsumption bp 0 h : ℝ) + ((bp.action 0 h : ℝ) - phi) =
          (1 + lambda) * K + wage * 1 ∧
        -phi ≤ (bp.action 0 h : ℝ) - phi := by
    intro h
    have hstep := plan_original_budget_initial bp prices K certaintyLaborOne hz_original h
    dsimp [prices, certaintyPrices] at hstep
    norm_num [certaintyLaborOne] at hstep ⊢
    exact hstep
  have hmprices : HEq m.prices prices.normalized := by
    dsimp [m, prices, certaintyHousehold]
    exact HEq.rfl
  refine ⟨prices, m, zstar, astar, cstar, bp, rfl, rfl, rfl, rfl, rfl, rfl, hmprices,
    rfl, rfl, rfl, hbetaR, ?_, ?_, hpath, hinitial, hbp_value, hdirect⟩
  · change K = K + phi - phi
    ring
  · linarith [hK]

end
end Aiyagari1994
