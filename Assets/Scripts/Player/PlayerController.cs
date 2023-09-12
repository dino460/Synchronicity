using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;
using TMPro;


namespace Player
{
    public enum State {Idle, Walk, Dash, Attack, Cancel, Hurt, Dead}
    public enum FacingDirection {Up, Down, Side}

    public class PlayerController : MonoBehaviour
    {

        public static event Action<PlayerController, Enemy.EnemyController> GetHurt;


        [Header("Components")]
        [SerializeField] private PlayerAnimationHandler playerAnimationHandler;
        [SerializeField] private PlayerInputHandler     playerInputHandler;
        [SerializeField] private Rigidbody2D            rigidbody2D;
        [SerializeField] private Transform              transform;
        [SerializeField] private GameObject             gameOverHUD;
        [SerializeField] private TextMeshProUGUI        HPGUI;
        [SerializeField] private TextMeshProUGUI        DashGUI;
        [SerializeField] private TextMeshProUGUI        EstusGUI;


        [Header("Movement")]
        [SerializeField] private Vector2 directionBuffer;

        [SerializeField] private float walkSpeed = 5f;
        [SerializeField] private float dashSpeed = 8f;

        [SerializeField] private float dashTime  = 2f;
        [SerializeField] private float dashTimer = 0f;
        
        [SerializeField] private float dashRechargeTime = 2f;
        [SerializeField] private float dashRechargeTimer;

        [SerializeField] private int maxDash = 3;
        [SerializeField] private int currentDash;


        [Header("Combat")]
        [SerializeField] private int comboValue = 0;
        public int p_comboValue
        {
            get { return comboValue; }
            set { if (state == State.Attack) comboValue = value; }
        }
        [SerializeField] private GameObject[] attackHitBoxes;
        [SerializeField] private float baseAttackDamage = 10;
        [SerializeField] private float upgradeDamageMod = 1f;
        [SerializeField] private float comboDamageMod   = 1.2f;
        [SerializeField] private float finalAttackDamage;
        [SerializeField] private string enemyHitboxTag;

        [SerializeField] private float knockbackForce = 10f;


        [Header("Health")]
        [SerializeField] private float maxHealthPoints = 50f;
        [SerializeField] private float currentHealthPoints;

        [SerializeField] private int maxEstusAmount  = 3;
        [SerializeField] private int currentEstusAmount;

        [SerializeField] private int estusHealingAmount = 26;


        [Header("States")]
        [SerializeField] private FacingDirection facingDirection;
        [SerializeField] private State state;


        // TODO: Somehow make upgrades happen and work
        // TODO: Refactor some messy methods and further separate functions into distinct methods
    
        #region Setup
        private void Start()
        {
            PlayerInputHandler.Dash             += Dash;
            PlayerInputHandler.Heal             += Heal;
            PlayerInputHandler.Attack           += Attack;
            PlayerAnimationHandler.End          += EndAnimation;
            PlayerAnimationHandler.Cancel       += CancelAttack;
            PlayerAnimationHandler.HitboxAttack += EnableAttackHitbox;
            Enemy.EnemyController.GetHurt       += DamageEnemy;

            state = State.Idle;
            facingDirection = FacingDirection.Down;

            comboValue = 0;
            currentHealthPoints = maxHealthPoints;
            currentEstusAmount  = maxEstusAmount;
            currentDash         = maxDash;

            directionBuffer = new Vector2(0f, -1f);

            HPGUI.text = "HP: " + currentHealthPoints.ToString() + "/" 
                + maxHealthPoints.ToString();
            DashGUI.text = "Dash: " + currentDash.ToString() + "/" 
                + maxDash.ToString();
            EstusGUI.text = "Estus: " + currentEstusAmount.ToString() + "/" 
                + maxEstusAmount.ToString();
        }

        private void Update()
        {
            if (state == State.Dead)
            {
                gameOverHUD.SetActive(true);
            }

            if (state != State.Attack && state != State.Dead)
            {
                if (state != State.Dash && state != State.Hurt)
                {
                    UpdateMovement();
                }
                
                if (state != State.Cancel)
                {
                    playerAnimationHandler.UpdateAnimation(state, (int) facingDirection);
                }
            }
        }

        private void FixedUpdate()
        {
            if (state == State.Dash) dashTimer++;
            if (dashTimer >= dashTime * 50f)
            {
                dashTimer = 0;
                state = State.Idle;
            }
            
            if (currentDash < maxDash) dashRechargeTimer++;
            if (dashRechargeTimer >= dashRechargeTime * 50f)
            {
                dashRechargeTimer = 0f;
                currentDash++;

                DashGUI.text = "Dash: " + currentDash.ToString() + "/" 
                + maxDash.ToString();
            }
        }

        private void OnTriggerEnter2D(Collider2D other)
        {
            if (other.tag == enemyHitboxTag)
            {
                GetHurt?.Invoke(this, other.gameObject.GetComponentInParent<Enemy.EnemyController>());
            }
        }

        #endregion


        #region Movement
        private void UpdateMovement()
        {
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
            if (state == State.Dash || state == State.Attack || currentDash <= 0) return;

            comboValue = 0;
            currentDash--;
            dashRechargeTimer = 0f;

            DashGUI.text = "Dash: " + currentDash.ToString() + "/" 
                + maxDash.ToString();

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

            finalAttackDamage = baseAttackDamage * Mathf.Pow(comboDamageMod, (comboValue / 3f)) * upgradeDamageMod;

            playerAnimationHandler.UpdateAnimation(state, comboValue + (int) facingDirection);
        }

        private void CancelAttack()
        {
            state = State.Cancel;
            attackHitBoxes[comboValue + (int) facingDirection].SetActive(false);
            comboValue += 3;
        }

        private void EnableAttackHitbox()
        {
            attackHitBoxes[comboValue + (int) facingDirection].SetActive(true); 
        }

        private void DamageEnemy(GameObject enemyController)
        {
            Vector2 knockback = directionBuffer;
            
            knockback *= (comboValue >= 4) ? knockbackForce : 0f;

            enemyController.GetComponent<Enemy.EnemyController>().TakeDamage(finalAttackDamage, knockback);
        }

        #endregion


        #region Health
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

            HPGUI.text = "HP: " + currentHealthPoints.ToString() + "/" 
                + maxHealthPoints.ToString();
            EstusGUI.text = "Estus: " + currentEstusAmount.ToString() + "/" 
                + maxEstusAmount.ToString();
        }

        public void TakeDamage(float damage, Vector2 knockback)
        {
            Debug.Log("Hurt Player");
            
            state = State.Hurt;
            rigidbody2D.velocity = Vector2.zero;

            rigidbody2D.AddForce(knockback, ForceMode2D.Impulse);

            currentHealthPoints -= damage;

            HPGUI.text = "HP: " + currentHealthPoints.ToString() + "/" 
                + maxHealthPoints.ToString();

            if (currentHealthPoints <= 0f) 
            {
                state = State.Dead;
                currentHealthPoints = 0f;
            }
        }

        #endregion


        private void EndAnimation()
        {
            state = State.Idle;
            comboValue = 0;
        }
    }
}
