using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using System;


namespace Player
{
    public class PlayerInputHandler : MonoBehaviour
    {
        private InputManager inputManager;


        [SerializeField]
        private float playerMovementThresshold = 0.05f;


        public static event Action Dash;
        public static event Action Heal;
        public static event Action Attack;


        private void OnEnable()
        {
            inputManager = new InputManager();

            inputManager.Player.Enable();
        }

        private void OnDisable() => inputManager.Player.Disable();

        private void Start()
        {
            inputManager.Player.Dash.performed   += _0 => Dash?.Invoke();
            inputManager.Player.Heal.performed   += _0 => Heal?.Invoke();
            inputManager.Player.Attack.performed += _0 => Attack?.Invoke();
            inputManager.Player.debug.performed += _0 => ExitGame();
        }

        private void ExitGame()
        {
            Debug.Log("Quit");
            Application.Quit();
        }


        public Vector2 PlayerDirectionThisFrame()
        {
            return inputManager.Player.Movement.ReadValue<Vector2>();
        }

        public bool PlayerIsMovingThisFrame()
        {
            return inputManager.Player.Movement.ReadValue<Vector2>().magnitude > 
                    playerMovementThresshold;
        }
    }
}
