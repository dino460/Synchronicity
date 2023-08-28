using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;


namespace Player
{
    public class PlayerAnimationHandler : MonoBehaviour
    {
        [SerializeField] private PlayerController playerController;
        [SerializeField] private Animator anim;
        

        // 0: Up (U) | 1: Down (D) | 2: Side (S)
        [Header("Animation Clips")]
        [SerializeField] private AnimationClip[] idleAnimations;
        [SerializeField] private AnimationClip[] walkAnimations;
        [SerializeField] private AnimationClip[] dashAnimations;

        // 0-2: Attack 1 | 3-5: Attack 2 | 6-8: Attack 3
        // Directions and combo are accessed by doing 'comboValue + (int) p_direction'
        // comboVaue increases by 3 on last frames of attacks 1 & 2
        [SerializeField] private AnimationClip[] attackAnimations;


        public static event Action Cancel;
        public static event Action End;
        public static event Action HitboxAttack;


        public void UpdateAnimation(State p_state, int p_direction)
        {
            switch (p_state)
            {
                case State.Idle:
                    anim.Play(idleAnimations[p_direction].name);
                    break;
                
                case State.Walk:
                    anim.Play(walkAnimations[p_direction].name);
                    break;
                
                case State.Dash:
                    anim.Play(dashAnimations[p_direction].name);
                    break;
                
                case State.Attack:
                    anim.Play(attackAnimations[p_direction].name);
                    // playerController.p_comboValue += 3;
                    break;
                
                default:
                    break;
            }
        }


        public void CancelAnimation()
        {
            Cancel?.Invoke();
        }

        public void EndAnimation()
        {
            End?.Invoke();
        }

        public void EnableAttackHitbox()
        {
            HitboxAttack?.Invoke();
            // Somehow enable right hitbox based on combo value
            // Debug.Log("Yes, I am definetely enabling a collider");
        }
    }
}
