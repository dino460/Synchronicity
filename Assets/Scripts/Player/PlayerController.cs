using System.Collections.Generic;
using System.Collections;
using UnityEngine;


namespace Player
{
    // TODO: Somehow make upgrades happen and work
    
    public enum State {Idle, Walk, Dash, Attack, Cancel}
    public enum FacingDirection {Up, Down, Side}

    public class PlayerController : MonoBehaviour
    {
        [Header("Components")]
        [SerializeField] private PlayerAnimationHandler playerAnimationHandler;
        [SerializeField] private PlayerInputHandler     playerInputHandler;
        [SerializeField] private Rigidbody2D            rigidbody2D;
        [SerializeField] private Transform              transform;


        [Header("Movement")]
        [SerializeField] private Vector2 directionBuffer;

        [SerializeField] private float walkSpeed = 5f;
        [SerializeField] private float dashSpeed = 8f;

        [SerializeField] private float dashTime  = 2f;
        [SerializeField] private float dashTimer = 0f;


        [Header("Combat")]
        [SerializeField] private int comboValue = 0;
        public int p_comboValue
        {
            get { return comboValue; }
            set { if (state == State.Attack) comboValue = value; }
        }
        [SerializeField] private GameObject[] attackHitBoxes;
        [SerializeField] private float attackDamage = 10;
        [SerializeField] private float comboDamageMod = 1.2;


        [Header("Health")]
        [SerializeField] private float maxHealthPoints = 50;
        [SerializeField] private float currentHealthPoints;

        [SerializeField] private int maxEstusAmount  = 3;
        [SerializeField] private int currentEstusAmount;

        [SerializeField] private int estusHealingAmount = 26;


        [Header("States")]
        [SerializeField] private FacingDirection facingDirection;
        [SerializeField] private State state;


        #region Setup
        private void Start()
        {
            PlayerInputHandler.Dash             += Dash;
            PlayerInputHandler.Heal             += Heal;
            PlayerInputHandler.Attack           += Attack;
            PlayerAnimationHandler.End          += EndAttack;
            PlayerAnimationHandler.Cancel       += CancelAttack;
            PlayerAnimationHandler.HitboxAttack += EnableAttackHitbox;

            state = State.Idle;
            facingDirection = FacingDirection.Down;

            comboValue = 0;
            currentHealthPoints = maxHealthPoints;
            currentEstusAmount  = maxEstusAmount;

            directionBuffer = new Vector2(0f, -1f);
        }

        private void Update()
        {
            UpdateMovement();

            
            if (state != State.Attack && state != State.Cancel)
            {
                playerAnimationHandler.UpdateAnimation(state, (int) facingDirection);
            }
        }

        private void FixedUpdate()
        {
            if (state == State.Dash) dashTimer += 0.02f;

            if (dashTimer >= dashTime)
            {
                dashTimer = 0;
                state = State.Idle;
            }
        }

        #endregion


        #region Movement
        private void UpdateMovement()
        {
            if (state == State.Dash || state == State.Attack) return;

            if (playerInputHandler.PlayerIsMovingThisFrame())
            {
                comboValue = 0;
                
                directionBuffer = playerInputHandler.PlayerDirectionThisFrame();
                
                UpdateFacingDirection();

                state = State.Walk;

                rigidbody2D.velocity = 
                    playerInputHandler.PlayerDirectionThisFrame() * walkSpeed;
            }
            else if (state != State.Cancel)
            {
                state = State.Idle;
                rigidbody2D.velocity = Vector2.zero;
            }
        }

        private void Dash()
        {
            if (state == State.Dash || state == State.Attack) return;

            comboValue = 0;

            if (playerInputHandler.PlayerIsMovingThisFrame())
            {
                directionBuffer = playerInputHandler.PlayerDirectionThisFrame();

                UpdateFacingDirection();

                state = State.Dash;

                rigidbody2D.velocity = 
                    playerInputHandler.PlayerDirectionThisFrame() * dashSpeed;
            }
            else
            {
                UpdateFacingDirection();

                state = State.Dash;

                rigidbody2D.velocity = directionBuffer * dashSpeed;
            }
        }

        private void UpdateFacingDirection()
        {
            if (Mathf.Abs(directionBuffer.y) >= 
                Mathf.Abs(directionBuffer.x))
            {
                if (directionBuffer.y > 0f)
                {
                    facingDirection = FacingDirection.Up;
                }
                else
                {
                    facingDirection = FacingDirection.Down;
                }
            }
            else
            {
                facingDirection = FacingDirection.Side;

                if (directionBuffer.x >= 0f)
                {
                    transform.localScale = new Vector2(1f, 1f);
                }
                else
                {
                    transform.localScale = new Vector2(-1f, 1f);
                } 
            }
        }

        #endregion


        #region Combat
        private void Attack()
        {
            if (state == State.Dash || state == State.Attack || comboValue >= 7) return;
            
            state = State.Attack;
            rigidbody2D.velocity = Vector2.zero;

            playerAnimationHandler.UpdateAnimation(state, comboValue + (int) facingDirection);
        }

        private void CancelAttack()
        {
            state = State.Cancel;
            attackHitBoxes[comboValue + (int) facingDirection].SetActive(false);
            comboValue += 3;
        }

        private void EndAttack()
        {
            state = State.Idle;
            comboValue = 0;
        }

        private void EnableAttackHitbox()
        {
            attackHitBoxes[comboValue + (int) facingDirection].SetActive(true); 
        }

        #endregion


        #region Healing
        private void Heal()
        {
            if (currentEstusAmount <= 0)
            {
                currentEstusAmount = 0;
                return;
            }

            currentHealthPoints += estusHealingAmount;
            currentEstusAmount--;

            if (currentHealthPoints >= maxHealthPoints) currentHealthPoints = maxHealthPoints;
        }

        private void TakeDamage(int damage)
        {
            currentHealthPoints -= damage;

            if (currentHealthPoints <= 0) currentHealthPoints = 0;
        }

        #endregion
    }
}
