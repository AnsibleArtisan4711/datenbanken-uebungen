#!/usr/bin/env python3
"""Mini-Modell eines Dokumentenspeichers (KEIN MongoDB): Einfügen, Suchen mit Operatoren, Projektion, Ändern, verschachtelte Felder. Erfundene Daten."""
import json, copy
class Sammlung:
    def __init__(self): self.docs = []; self.n = 0
    def einfuegen(self, d): self.n += 1; d = copy.deepcopy(d); d['_id'] = self.n; self.docs.append(d); return self.n
    @staticmethod
    def _hole(d, pfad):
        for p in pfad.split('.'):
            if not isinstance(d, dict) or p not in d: return None
            d = d[p]
        return d
    def _passt(self, d, f):
        for k, b in f.items():
            w = self._hole(d, k)
            if isinstance(b, dict):
                for op, x in b.items():
                    if op == '$gt' and not (w is not None and w > x): return False
                    if op == '$lt' and not (w is not None and w < x): return False
                    if op == '$in' and w not in x: return False
                    if op not in ('$gt', '$lt', '$in'): raise ValueError('Operator nicht im Modell: ' + op)
            elif w != b: return False
        return True
    def finde(self, f=None, felder=None):
        r = [d for d in self.docs if self._passt(d, f or {})]
        if felder: r = [{k: self._hole(d, k) for k in felder} for d in r]
        return r
    def aendere(self, f, setze):
        n = 0
        for d in self.docs:
            if self._passt(d, f):
                for k, v in setze.items():
                    ziel = d; teile = k.split('.')
                    for p in teile[:-1]: ziel = ziel.setdefault(p, {})
                    ziel[teile[-1]] = v
                n += 1
        return n
