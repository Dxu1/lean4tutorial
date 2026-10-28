"""Narrow E02 header/suffix policy within the shared_imports certificate system.

Header imports can alter earlier elaboration: exact fingerprints remain mandatory.
Suffix context commands are sequential and cannot affect preceding declarations.
Neither fact establishes mathematical adequacy of the appended theorem.
"""
import re
from shared_imports import sha, fail

CLASSIFICATION = 'SHARED_WRAPPER_HEADER_IMPORT_AND_SUFFIX_RECONCILIATION'
GATE = 'M10B2'
CONTRACT = 'E02'
PREAMBLE = ['noncomputable section', 'open MeasureTheory']


def regions(original, candidate, policy):
    """Recognize exactly A + B + C, without normalizing a single accepted byte."""
    if not original or candidate.count(original) != 1:
        fail('SHARED_WRAPPER_AMBIGUOUS_ACCEPTED_REGION')
    start = candidate.index(original)
    header = candidate[:start]
    expected = ('import ' + policy['imports'][0]).encode()
    if len(policy['imports']) != 1 or not re.fullmatch(rb'[ \t\r\n]*' + re.escape(expected) + rb'\n[ \t\r\n]*', header):
        fail('UNAUTHORIZED_HEADER_IMPORT_DELTA')
    end = start + len(original)
    suffix = candidate[end:]
    from orchestrate import strip_lean_comments
    text = strip_lean_comments(suffix.decode())
    lines = [s.strip() for s in text.splitlines() if s.strip()]
    if not lines or lines.pop(0) != 'namespace Aiyagari1994':
        fail('UNAUTHORIZED_SUFFIX_NAMESPACE')
    preamble = []
    for command in PREAMBLE:
        if lines and lines[0] == command:
            preamble.append(lines.pop(0))
    closing = ['end', 'end Aiyagari1994'] if 'noncomputable section' in preamble else ['end Aiyagari1994']
    if lines[-len(closing):] != closing:
        fail('UNAUTHORIZED_SUFFIX_NAMESPACE')
    body = '\n'.join(lines[:-len(closing)])
    declarations = policy['new_declarations']
    if len(declarations) != 1:
        fail('UNAUTHORIZED_APPENDED_DECLARATION')
    name = declarations[0].removeprefix('Aiyagari1994.')
    if not re.match(r'theorem ' + re.escape(name) + r'\b', body):
        fail('UNAUTHORIZED_APPENDED_DECLARATION')
    # This exception is for a thin theorem wrapper, not a general Lean parser.
    # Reject commands anywhere on a fresh line, including indented commands.
    forbidden = r'(?:import|open|export|attribute|local|instance|def|abbrev|lemma|axiom|opaque|macro|syntax|notation|elab|set_option|section|noncomputable|private|protected|mutual|namespace|end|#|@)'
    if re.search(r'(?m)^\s*' + forbidden + r'\b', body) or re.search(r'(?m)^\s*theorem\b', body[len('theorem '):]):
        fail('UNAUTHORIZED_SUFFIX_COMMAND')
    # Exactly one declaration with a direct application as its proof. No command
    # can hide after a semicolon, inside a tactic block or string literal.
    if ':=' not in body:
        fail('UNAUTHORIZED_SUFFIX_COMMAND')
    signature, proof = body.rsplit(':=', 1)
    if any(x in signature for x in [';', '"', '`', '#', '@[']) or not re.fullmatch(r'[\w. \t]+', proof.strip()):
        fail('UNAUTHORIZED_SUFFIX_COMMAND')
    return {'gate':GATE, 'contract':CONTRACT, 'accepted_source_sha256':sha(original),
            'candidate_sha256':sha(candidate), 'header_sha256':sha(header),
            'added_header_imports':policy['imports'], 'accepted_start':start,
            'accepted_end':end, 'suffix_sha256':sha(suffix),
            'authorized_suffix_preamble':preamble, 'new_declarations':declarations,
            'suffix_command_sequence':['namespace Aiyagari1994'] + preamble +
                                      ['theorem '+name] + closing,
            'header_semantics_require_exact_fingerprints':True,
            'suffix_context_after_accepted_boundary':True}


def validate_graph(root, graph, policy, accepted_sources):
    """Every transitive project import is accepted or in the E02 helper scope."""
    from pathlib import Path
    wrapper = policy['module'][:-5].replace('/', '.')
    for module in graph:
        path = module.replace('.', '/') + '.lean'
        if module == wrapper:
            fail('IMPORT_CYCLE: shared wrapper imported back')
        if path not in accepted_sources and not path.startswith('Aiyagari1994/Analysis/M10B2/'):
            fail('UNAUTHORIZED_DEPENDENCY: '+module)
        if not (Path(root)/path).is_file():
            fail('MISSING_PROJECT_IMPORT: '+module)
    for module in policy['imports']:
        if not module.startswith('Aiyagari1994.Analysis.M10B2.') or module not in graph:
            fail('UNAUTHORIZED_HEADER_IMPORT_OWNER')


def validate_certificate(cert, original, candidate, policy):
    if cert.get('header_suffix') != regions(original, candidate, policy):
        fail('SHARED_WRAPPER_HEADER_SUFFIX_CERTIFICATE_MISMATCH')
    if cert.get('incident_classification') != CLASSIFICATION:
        fail('SHARED_WRAPPER_HEADER_SUFFIX_CLASSIFICATION')
