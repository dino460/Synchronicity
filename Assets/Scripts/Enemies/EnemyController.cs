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
        [SerializeField] private Transform player;
        [SerializeField] private Transform thisTransform;


        [Header("Movement")]
        [SerializeField] private float moveSpeed;
        [SerializeField] private float alignSpeed = 2f;
        [SerializeField] private float alignMargin = 0.05f;


        [Header("Combat")]
        [SerializeField] private float testForAttackTimer = 0f;
        [SerializeField] private float timeToTestForAttack = 2f;        

        [SerializeField] private float timeToAlign;
        [SerializeField] private float alignTimer = 0f;
        [SerializeField] private bool  alignTimerIsSet = false;
        [SerializeField] private int   alignModifier = 1; 

        [SerializeField] private bool canTestForAttack = false;
        [SerializeField] private bool firstAttack = true;


        // TODO: Make it patrol when far from player
        // TODO: Make it not leave a certain distance from its spawn point

        private void Start()
        {
            EnemyAnimationController.End += ExitAttack;

            state = State.Idle;

            agent.updateRotation = false;
            agent.updateUpAxis   = false;
            canTestForAttack     = false;
            alignTimerIsSet      = false;
            firstAttack          = true;

            alignModifier = (int) agent.transform.localScale.x;

            target = player.position;
            agent.SetDestination(
                    new Vector3(target.x, target.y, thisTransform.position.z));
        }

        void Update()
        {
            TurnThis();

            target = player.position;

            
            if (Vector2.Distance(agent.transform.position, target) <= 
                agent.stoppingDistance)
            {
                AlignToAttack();
            }
            else if (state != State.Attack && state != State.Dead && state != State.Hurt)
            {
                testForAttackTimer = 0f;
                alignTimer = 0f;
                alignModifier = (int) agent.transform.localScale.x;
                alignTimerIsSet = false;
                firstAttack = true;

                state = State.Walk;

                agent.SetDestination(
                    new Vector3(target.x, target.y, thisTransform.position.z));
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
        }


        private void AlignToAttack()
        {
            if (state == State.Attack) return;

            state = State.Align;

            var destination = new Vector2(target.x - 
                (alignModifier * agent.stoppingDistance), 
                target.y - 0.5f);
            

            float distance = Vector2.Distance(destination, agent.transform.position);

            if (!alignTimerIsSet)
            {
                alignTimerIsSet = true;
                timeToAlign = 2f * distance / alignSpeed;
            }


            if (Vector2.Distance(destination, agent.transform.position) <= 
                alignMargin)
            {
                state = State.Idle;
                canTestForAttack = true;
                return;
            }

            canTestForAttack = false;
            testForAttackTimer = 0f;

            agent.transform.position = Vector2.Lerp(agent.transform.position, 
                destination, alignSpeed * Time.deltaTime);
        }


        private void TurnThis()
        {
            if (state == State.Attack) return;

            if ((target - thisTransform.position).x >= 0f) 
            {
                agent.transform.localScale = new Vector2(1f, 1f);
            }
            else
            {
                agent.transform.localScale = new Vector2(-1f, 1f);
            }
        }


        private void TestForAttack()
        {
            if (!canTestForAttack) return;

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

                state = State.Attack;
            }
        }

        private void ExitAttack()
        {
            state = State.Align;
        }
    }
}
