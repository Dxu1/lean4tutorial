"""Final Stage09 approved headline/accounting evidence only."""
def resolve(root,catalog,assigned,sid):
    if len(assigned)!=1 or assigned[0]['id'] not in {'G06','G07','G08'} or assigned[0]['stage']!='09' or sid!='A94':raise ValueError('Unauthorized Stage09d source')
    if 'PDF pp. 13-14' not in assigned[0]['source_locator']:raise ValueError('Stage09d source locator changed')
    return {13,14},['A94 printed670-671 / original PDF13-14, notes24-27. Capital/gross-investment comparisons and stationary accounting motivate the result; the exact universal, derivative and integrability Lean arguments are project reconstructions.'],False

def resolve_stage09(root,catalog,assigned,sid):
    if assigned and all(t['id'] in {'G06','G07','G08'} for t in assigned):return resolve(root,catalog,assigned,sid)
    from stage09c_sources import resolve_stage09 as previous
    return previous(root,catalog,assigned,sid)
