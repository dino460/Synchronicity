using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;


namespace Enemy
{
    public class EnemyAnimationController : MonoBehaviour
    {
        [SerializeField] private Animator anim;


        [SerializeField] private AnimationClip idleAnimation;
        [SerializeField] private AnimationClip walkAnimation;
        [SerializeField] private AnimationClip attackAnimation;


        public static event Action End;
        public static event Action HitboxHide;
        public static event Action HitboxAttack;


        public void UpdateAnimation(State e_state)
        {
            switch (e_state)
            {
                case State.Idle:
                    anim.Play(idleAnimation.name);
                    break;
                
                case State.Walk:
                    anim.Play(walkAnimation.name);
                    break;
                
                case State.Align:
                    anim.Play(walkAnimation.name);
                    break;
                
                case State.Attack:
                    anim.Play(attackAnimation.name);
                    break;
                
                case State.Hurt:
                    // anim.Play(attackAnimations[p_direction].name);
                    break;

                case State.Dead:
                    // anim.Play(attackAnimations[p_direction].name);
                    break;
                
                default:
                    break;
            }
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

        public void DisableAttackHitbox()
        {
            HitboxHide?.Invoke();
        }
    }
}
