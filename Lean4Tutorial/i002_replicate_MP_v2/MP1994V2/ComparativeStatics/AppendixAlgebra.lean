import Mathlib

/-! # Scalar algebra for the MP1994 Appendix

This file deliberately contains no economic structures.  It isolates scalar
field normalization used throughout the Appendix.
-/

namespace MP1994V2

/-- Normalize differentiated, cross-multiplied job creation using the base
job-creation identity. -/
theorem appendixA2_normalize
    {q qp thetaSlope cutoffSlope gap c a sigma R : ℝ}
    (hgap : gap ≠ 0) (ha : a ≠ 0) (hsigma : sigma ≠ 0) (hR : R ≠ 0)
    (hRaw : qp * thetaSlope * gap - q * cutoffSlope = c / (a * sigma))
    (hJC : q * a * (sigma / R) * gap = c) :
    qp * thetaSlope = q / R + (q / gap) * cutoffSlope := by
  have hcost : c / (a * sigma) = q * gap / R := by
    calc
      c / (a * sigma) =
          (q * a * (sigma / R) * gap) / (a * sigma) := by rw [hJC]
      _ = q * gap / R := by
        field_simp [ha, hsigma, hR]
  rw [hcost] at hRaw
  have hRaw' :
      qp * thetaSlope * gap = q * cutoffSlope + q * gap / R := by
    linarith [hRaw]
  calc
    qp * thetaSlope =
        (q * cutoffSlope + q * gap / R) / gap := by
      apply (eq_div_iff hgap).2
      simpa using hRaw'
    _ = q / R + (q / gap) * cutoffSlope := by
      field_simp [hR, hgap]
      ring

/-- Paper-facing cost form of equation (A2). -/
theorem appendixA2_paper
    {q qp thetaSlope cutoffSlope gap c a sigma R : ℝ}
    (hgap : gap ≠ 0) (ha : a ≠ 0) (hsigma : sigma ≠ 0) (hR : R ≠ 0)
    (hNormalized : qp * thetaSlope = q / R + (q / gap) * cutoffSlope)
    (hJC : q * a * (sigma / R) * gap = c) :
    qp * thetaSlope =
      c / (a * sigma * gap) +
        c * R / (a * sigma * gap ^ 2) * cutoffSlope := by
  have hq : q = c * R / (a * sigma * gap) := by
    calc
      q = (q * a * (sigma / R) * gap) * R /
          (a * sigma * gap) := by
        field_simp [ha, hsigma, hR, hgap]
      _ = c * R / (a * sigma * gap) := by rw [hJC]
  calc
    qp * thetaSlope = q / R + (q / gap) * cutoffSlope := hNormalized
    _ = c / (a * sigma * gap) +
        c * R / (a * sigma * gap ^ 2) * cutoffSlope := by
      rw [hq]
      field_simp [ha, hsigma, hR, hgap]

/-- Pure algebraic substitution of normalized (A1) into normalized (A2),
yielding equation (A3). -/
theorem appendixA3_of_A1_A2
    {sigma B R K thetaSlope cutoffSlope r H q qp gap : ℝ}
    (hsigma : sigma ≠ 0) (hB : B ≠ 0) (hR : R ≠ 0)
    (hgap : gap ≠ 0)
    (hA1 : sigma * (B / R) * cutoffSlope =
      K * thetaSlope - sigma * (r / R ^ 2) * H)
    (hA2 : qp * thetaSlope = q / R + (q / gap) * cutoffSlope) :
    (qp - K * R * q / (sigma * B * gap)) * thetaSlope =
      (q / R) * (1 - r * H / (B * gap)) := by
  field_simp [hsigma, hB, hR, hgap] at hA1 hA2 ⊢
  linear_combination sigma * B * hA2 + q * hA1

/-- Solve normalized equation (A5) for the cutoff slope. -/
theorem appendixA5_solve
    {sigma B R K thetaSlope cutoffSlope lambda H : ℝ}
    (hsigma : sigma ≠ 0) (hB : B ≠ 0) (hR : R ≠ 0)
    (hA5 : sigma * (B / R) * cutoffSlope =
      K * thetaSlope + lambda * sigma / R ^ 2 * H) :
    cutoffSlope =
      K * R / (sigma * B) * thetaSlope + lambda / (R * B) * H := by
  field_simp [hsigma, hB, hR] at hA5 ⊢
  linear_combination hA5

/-- Convert normalized job creation to the matching-elasticity form (A7). -/
theorem appendixA7_of_normalized_A6
    {q qp eta theta R gap thetaSlope cutoffSlope : ℝ}
    (hq : q ≠ 0) (heta : eta ≠ 0) (htheta : theta ≠ 0)
    (hR : R ≠ 0) (hgap : gap ≠ 0)
    (hqp : qp = -(eta * q / theta))
    (hA6 : qp * thetaSlope = q / R + (q / gap) * cutoffSlope) :
    thetaSlope =
      -theta / (eta * R) - theta / (eta * gap) * cutoffSlope := by
  rw [hqp] at hA6
  field_simp [hq, htheta, hR, hgap] at hA6
  field_simp [heta, hR, hgap]
  linear_combination -hA6

/-- Substitute (A5) and (A7) to obtain equation (A8). -/
theorem appendixA8_of_A5_A7
    {cutoffSlope thetaSlope K R sigma B lambda H theta eta gap : ℝ}
    (hsigma : sigma ≠ 0) (hB : B ≠ 0) (hR : R ≠ 0)
    (heta : eta ≠ 0) (hgap : gap ≠ 0)
    (hA5 : cutoffSlope =
      K * R / (sigma * B) * thetaSlope + lambda / (R * B) * H)
    (hA7 : thetaSlope =
      -theta / (eta * R) - theta / (eta * gap) * cutoffSlope) :
    (1 + K * R * theta / (sigma * B * eta * gap)) * cutoffSlope =
      1 / (sigma * B) *
        (-K * theta / eta + lambda * sigma / R * H) := by
  have h := hA5
  rw [hA7] at h
  field_simp [hsigma, hB, hR, heta, hgap] at h ⊢
  ring_nf at h ⊢
  linear_combination h

/-- Normalize the differentiated dispersion JD condition to equation (A9). -/
theorem appendixA9_normalize
    {d sigma cutoffSlope K thetaSlope lambda R H F B r : ℝ}
    (hR : R ≠ 0) (hRdef : R = r + lambda)
    (hBdef : B = r + lambda * F)
    (hRaw : d + sigma * cutoffSlope - K * thetaSlope + lambda / R * H -
      lambda * sigma / R * (1-F) * cutoffSlope = 0) :
    sigma * (B/R) * cutoffSlope =
      K*thetaSlope-d-lambda/R*H := by
  subst R
  subst B
  field_simp [hR] at hRaw ⊢
  linear_combination hRaw

/-- Derive paper equation (A10) from cross-multiplied job creation. -/
theorem appendixA10_of_crossMultiplied
    {q qp eta theta sigma gap thetaSlope cutoffSlope : ℝ}
    (hq : q ≠ 0) (htheta : theta ≠ 0)
    (hqp : qp = -(eta*q/theta))
    (hRaw : qp*thetaSlope*sigma*gap + q*gap -
      q*sigma*cutoffSlope = 0) :
    sigma*gap*(eta/theta)*thetaSlope = gap-sigma*cutoffSlope := by
  rw [hqp] at hRaw
  have hfactor :
      q * (-(eta / theta) * thetaSlope * sigma * gap + gap -
        sigma * cutoffSlope) = 0 := by
    ring_nf at hRaw ⊢
    exact hRaw
  have hRaw' :
      -(eta / theta) * thetaSlope * sigma * gap + gap -
        sigma * cutoffSlope = 0 :=
    (mul_eq_zero.mp hfactor).resolve_left hq
  field_simp [htheta] at hRaw' ⊢
  linear_combination -hRaw'

/-- Combine (A9) and (A10) into the A11 tightness-slope equation. -/
theorem appendixA11_slopeEquation_of_A9_A10
    {sigma B R K thetaSlope cutoffSlope lambda H theta eta gap epsUpper d F : ℝ}
    (hR : R ≠ 0) (htheta : theta ≠ 0)
    (hgapDef : gap = epsUpper-d) (hRB : R-B = lambda*(1-F))
    (hA9 : sigma*(B/R)*cutoffSlope =
      K*thetaSlope-d-lambda/R*H)
    (hA10 : sigma*gap*(eta/theta)*thetaSlope =
      gap-sigma*cutoffSlope) :
    (K*R+B*sigma*gap*eta/theta)*thetaSlope =
      B*epsUpper+lambda*(d*(1-F)+H) := by
  have hA9R :
      sigma * B * cutoffSlope =
        K * R * thetaSlope - R * d - lambda * H := by
    calc
      sigma * B * cutoffSlope =
          R * (sigma * (B / R) * cutoffSlope) := by
        field_simp [hR]
      _ = R * (K * thetaSlope - d - lambda / R * H) := by
        rw [hA9]
      _ = K * R * thetaSlope - R * d - lambda * H := by
        field_simp [hR]
  have hBalance :
      K * R * thetaSlope - B * sigma * cutoffSlope =
        R * d + lambda * H := by
    linarith [hA9R]
  calc
    (K * R + B * sigma * gap * eta / theta) * thetaSlope =
        K * R * thetaSlope +
          B * (sigma * gap * (eta / theta) * thetaSlope) := by ring
    _ = K * R * thetaSlope + B * (gap - sigma * cutoffSlope) := by
      rw [hA10]
    _ = B * gap +
        (K * R * thetaSlope - B * sigma * cutoffSlope) := by ring
    _ = B * gap + R * d + lambda * H := by
      rw [hBalance]
      ring
    _ = B * epsUpper + lambda * (d * (1 - F) + H) := by
      rw [hgapDef]
      have hRrewrite : R = B + lambda * (1 - F) := by
        linarith [hRB]
      rw [hRrewrite]
      ring

/-- Combine (A9) and (A10) into the A12 cutoff-slope equation. -/
theorem appendixA12_slopeEquation_of_A9_A10
    {sigma B R K thetaSlope cutoffSlope lambda H theta eta gap d : ℝ}
    (hsigma : sigma ≠ 0) (hR : R ≠ 0) (heta : eta ≠ 0)
    (htheta : theta ≠ 0) (hgap : gap ≠ 0)
    (hA9 : sigma*(B/R)*cutoffSlope =
      K*thetaSlope-d-lambda/R*H)
    (hA10 : sigma*gap*(eta/theta)*thetaSlope =
      gap-sigma*cutoffSlope) :
    (sigma*B/R+K*theta/(eta*gap))*cutoffSlope =
      (1/sigma)*(K*theta/eta-sigma*d-lambda*sigma/R*H) := by
  field_simp [hsigma, hR, heta, htheta, hgap] at hA9 hA10 ⊢
  linear_combination sigma*eta*gap*hA9+K*R*hA10

end MP1994V2
