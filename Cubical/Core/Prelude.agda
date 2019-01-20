{-

This file proves a variety of basic results about paths:

- refl, sym, cong and composition of paths. This is used to set up
  equational reasoning.

- Subst and functional extensionality

- J and its computation rule (up to a path)

- Σ-types and contractibility of singletons

- Converting PathP to and from a homogeneous path with transp

- Direct definitions of lower h-levels

- Export natural numbers

-}
{-# OPTIONS --cubical --safe #-}
module Cubical.Core.Prelude where

open import Agda.Builtin.Sigma public

open import Cubical.Core.Primitives public

-- Basic theory about paths. These proofs should typically be
-- inlined. This module also makes equational reasoning work with
-- (non-dependent) paths.

private
  variable
    ℓ ℓ' : Level
    A : Set ℓ
    B : A → Set ℓ'
    x y z : A

refl : x ≡ x
refl {x = x} = λ _ → x

sym : x ≡ y → y ≡ x
sym p = λ i → p (~ i)

cong : ∀ (f : (a : A) → B a) (p : x ≡ y)
       → PathP (λ i → B (p i)) (f x) (f y)
cong f p = λ i → f (p i)

-- This is called compPath and not trans in order to eliminate
-- confusion with transp
compPath : x ≡ y → y ≡ z → x ≡ z
compPath {x = x} p q i =
  hcomp (λ j → \ { (i = i0) → x
                 ; (i = i1) → q j }) (p i)

infix  3 _≡-qed _∎
infixr 2 _≡⟨⟩_ _≡⟨_⟩_
infix  1 ≡-proof_ begin_

≡-proof_ begin_ : x ≡ y → x ≡ y
≡-proof x≡y = x≡y
begin_ = ≡-proof_

_≡⟨⟩_ : (x : A) → x ≡ y → x ≡ y
_ ≡⟨⟩ x≡y = x≡y

_≡⟨_⟩_ : (x : A) → x ≡ y → y ≡ z → x ≡ z
_ ≡⟨ x≡y ⟩ y≡z = compPath x≡y y≡z

_≡-qed _∎ : (x : A) → x ≡ x
_ ≡-qed  = refl
_∎ = _≡-qed

-- Subst and functional extensionality

module _ (B : A → Set ℓ') where

  subst : (p : x ≡ y) → B x → B y
  subst p pa = transp (λ i → B (p i)) i0 pa

  substRefl : (px : B x) → subst refl px ≡ px
  substRefl {x = x} px i = transp (λ _ → B x) i px

funExt : {f g : (x : A) → B x} → ((x : A) → f x ≡ g x) → f ≡ g
funExt p i x = p x i

-- Transporting in a constant family is the identity function (up to a
-- path). If we would have regularity this would be definitional.
transpRefl : (A : Set ℓ) (u0 : A) →
             PathP (λ _ → A) (transp (λ _ → A) i0 u0) u0
transpRefl A u0 i = transp (λ _ → A) i u0


-- J for paths and its computation rule

module _ (P : ∀ y → x ≡ y → Set ℓ') (d : P x refl) where
  J : (p : x ≡ y) → P y p
  J p = transp (λ i → P (p i) (λ j → p (i ∧ j))) i0 d

  JRefl : J refl ≡ d
  JRefl i = transp (λ _ → P x refl) i d

-- Σ-types

_×_ : (A : Set ℓ) (B : Set ℓ') → Set (ℓ-max ℓ ℓ')
A × B = Σ A (λ _ → B)

infixr 5 _×_
infix 2 Σ-syntax

Σ-syntax : (A : Set ℓ) (B : A → Set ℓ') → Set (ℓ-max ℓ ℓ')
Σ-syntax = Σ

syntax Σ-syntax A (λ x → B) = Σ[ x ∈ A ] B


-- Contractibility of singletons

singl : {A : Set ℓ} (a : A) → Set ℓ
singl {A = A} a = Σ[ x ∈ A ] (a ≡ x)

contrSingl : (p : x ≡ y) → Path (singl x) (x , refl) (y , p)
contrSingl p i = (p i , λ j → p (i ∧ j))


-- Converting to and from a PathP

module _ {A : I → Set ℓ} {x : A i0} {y : A i1} where
  toPathP : transp A i0 x ≡ y → PathP A x y
  toPathP p i = hcomp (λ j → λ { (i = i0) → x
                               ; (i = i1) → p j })
                      (transp (λ j → A (i ∧ j)) (~ i) x)

  fromPathP : PathP A x y → transp A i0 x ≡ y
  fromPathP p i = transp (λ j → A (i ∨ j)) i (p i)


-- Direct definitions of lower h-levels

isContr : Set ℓ → Set ℓ
isContr A = Σ[ x ∈ A ] (∀ y → x ≡ y)

isProp : Set ℓ → Set ℓ
isProp A = (x y : A) → x ≡ y

isSet : Set ℓ → Set ℓ
isSet A = (x y : A) → isProp (x ≡ y)

open import Agda.Builtin.Nat public
  using (zero; suc; _+_; _*_)
  renaming (Nat to ℕ)
