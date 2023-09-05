using System.Collections.Generic;
using System.Collections;
using UnityEngine.AI;
using UnityEngine;


namespace Enemy
{
    public enum State {Idle, Walk, Align, Attack, Hurt, Dead}
    
    public class MudGuardController : MonoBehaviour
    {
        [SerializeField] private State state = State.Idle;

        private Vector3 target;


        [SerializeField] private EnemyAnimationController enemyAnimationController;
        [SerializeField] private NavMeshAgent agent;
        [SerializeField] private Player.PlayerInputHandler playerInputHandler;
        [SerializeField] private Transform player;
        [SerializeField] private Transform thisTransform;
        [SerializeField] private Transform spriteTransform;


        [Header("Movement")]
        [SerializeField] private float moveSpeed;
        [SerializeField] private float alignSpeed    = 2f;
        [SerializeField] private float alignMargin   = 0.05f;
        [SerializeField] private float alignDistance = 0.5f;


        [Header("Combat")]
        [SerializeField] private float testForAttackTimer  = 0f;
        [SerializeField] private float timeToTestForAttack = 2f;        

        [SerializeField] private float timeToAlign;
        [SerializeField] private float alignTimer      = 0f;
        [SerializeField] private bool  alignTimerIsSet = false;
        [SerializeField] private int   alignModifier   = 1; 

        [SerializeField] private bool canTestForAttack = false;
        [SerializeField] private bool firstAttack      = true;


        [Header("Damage")]
        [SerializeField] private string playerHitboxTag;

        [SerializeField] private int hitCount               = 0;
        [SerializeField] private int hitCountToInvulnerable = 3;
        
        [SerializeField] private float invulnerableTimer = 0f;
        [SerializeField] private float invulnerableTime  = 2f;
        [SerializeField] private bool  isInvulnerable    = false;

        [SerializeField] private float timeSinceLastHit  = 0f;
        [SerializeField] private float hitCountResetTime = 2.5f;


        // TODO: Make it patrol when far from player
        // TODO: Make it not leave a certain distance from its spawn point

        private void Start()
        {
            EnemyAnimationController.End    += ExitAttack;
            EnemyAnimationController.Unhurt += Unhurt;

            state = State.Idle;

            agent.updateRotation = false;
            agent.updateUpAxis   = false;
            canTestForAttack     = false;
            alignTimerIsSet      = false;
            firstAttack          = true;
            isInvulnerable       = false;

            alignModifier = (int) agent.transform.localScale.x;

            target = player.position;

            agent.SetDestination(
                    new Vector3(target.x, target.y, thisTransform.position.z));
        }

        void Update()
        {
            TurnThis();

            target = player.position;

            if (hitCount == hitCountToInvulnerable)
            {
                hitCount = 0;
                isInvulnerable = true;
            }
            
            if (state != State.Attack && state != State.Hurt && state != State.Dead)
            {    
                if (Vector2.Distance(agent.transform.position, target) <= 
                    agent.stoppingDistance)
                {
                    AlignToAttack();
                }
                else
                {
                    agent.isStopped = false;

                    testForAttackTimer = 0f;
                    alignTimer = 0f;
                    alignModifier = (int) agent.transform.localScale.x;
                    alignTimerIsSet = false;
                    firstAttack = true;

                    state = State.Walk;

                    agent.SetDestination(
                        new Vector3(target.x, target.y, thisTransform.position.z));
                }
            }

            enemyAnimationController.UpdateAnimation(state);
        }

        private void FixedUpdate()
        {
            TestForAttack();


            if (alignTimerIsSet)
            {
                alignTimer++;
            }
            if (alignTimer >= timeToAlign * 50f)
            {
                alignTimer = 0f;
                alignModifier *= -1;
                alignTimerIsSet = false;
                // Do something to change align side
            }


            if (isInvulnerable)
            {
                invulnerableTimer++;
            }
            if (invulnerableTimer >= invulnerableTime * 50f)
            {
                invulnerableTimer = 0f;
                isInvulnerable = false;
            }

            
            timeSinceLastHit++;
            if (timeSinceLastHit >= hitCountResetTime * 50)
            {
                timeSinceLastHit = 0f;
                hitCount = 0;
            }
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (other.tag == playerHitboxTag)
            {
                Debug.Log("Hit");
                
                if (!isInvulnerable)
                {
                    timeSinceLastHit = 0f;
                    hitCount++;
                    state = State.Hurt;
                }
            }
        }


        private void TurnThis()
        {
            if (state == State.Attack) return;

            if ((target - thisTransform.position).x >= 0f) 
            {
                spriteTransform.localScale = new Vector2(1f, 1f);
            }
            else
            {
                spriteTransform.localScale = new Vector2(-1f, 1f);
            }
        }


        #region Combat

        private void AlignToAttack()
        {
            if (state == State.Attack || playerInputHandler.PlayerIsMovingThisFrame())
            {
                return;
            }

            agent.isStopped = true;
            state = State.Align;

            var destination = new Vector2(target.x - 
                (alignModifier * alignDistance), 
                target.y - 0.6f);
            

            float distance = Vector2.Distance(destination, agent.transform.position);

            if (!alignTimerIsSet)
            {
                alignTimerIsSet = true;
                timeToAlign = 2.2f * distance / alignSpeed;
            }


            if (Vector2.Distance(destination, agent.transform.position) <= 
                alignMargin)
            {
                state = State.Idle;
                canTestForAttack = true;
                return;
            }

            firstAttack = true;
            canTestForAttack = false;
            testForAttackTimer = 0f;

            agent.transform.position = Vector2.Lerp(agent.transform.position, 
                destination, alignSpeed * Time.deltaTime);
        }

        private void TestForAttack()
        {
            if (!canTestForAttack || playerInputHandler.PlayerIsMovingThisFrame())
            {
                return;
            }

            alignTimerIsSet = false;
            
            if (firstAttack)
            {
                testForAttackTimer = timeToTestForAttack * 50f;
                firstAttack = false;
            }

            if (state == State.Idle)
            {
                testForAttackTimer++;
            }

            if (testForAttackTimer >= timeToTestForAttack * 50f)
            {
                testForAttackTimer = 0f;
                alignTimer = 0f;

                state = State.Attack;
            }
        }

        private void ExitAttack()
        {
            state = State.Align;
        }

        #endregion
       

        #region TakeDamage

        private void Unhurt()
        {
            state = State.Idle;
        }
        
        #endregion
    }
}
