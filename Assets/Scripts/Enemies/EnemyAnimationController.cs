using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;


namespace Enemy
{
    public class EnemyAnimationController : MonoBehaviour
    {
        [SerializeField] private Animator anim;
        [SerializeField] private EnemyController _enemyController;


        [SerializeField] private AnimationClip idleAnimation;
        [SerializeField] private AnimationClip walkAnimation;
        [SerializeField] private AnimationClip attackAnimation;
        [SerializeField] private AnimationClip hurtAnimation;


        // public static event Action End;
        // public static event Action HitboxHide;
        // public static event Action HitboxAttack;
        // public static event Action Unhurt;


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
                    anim.Play(hurtAnimation.name);
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
            _enemyController.ExitAttack();
        }

        public void EnableAttackHitbox()
        {
            _enemyController.EnableAttackHitbox();
            // HitboxAttack?.Invoke();
            // Somehow enable right hitbox based on combo value
            // Debug.Log("Yes, I am definetely enabling a collider");
        }

        public void DisableAttackHitbox()
        {
            // HitboxHide?.Invoke();
            _enemyController.DisableAttackHitbox();
        }

        public void ExitHurt()
        {
            _enemyController.Unhurt();
            // Unhurt?.Invoke();
        }
    }
}
