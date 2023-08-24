using System.Collections.Generic;
using System.Collections;
using UnityEngine.AI;
using UnityEngine;


public class MudGuardController : MonoBehaviour
{
    private Vector3 target;


    [SerializeField] private NavMeshAgent agent;
    [SerializeField] private float moveSpeed;
    [SerializeField] private Transform player;

    // TODO: Make it align with player on the X axis
    // TODO: Make it turn to face the player
    
    // TODO: Make it attack player once in a while
    // TODO: Make it stop moving and turning when attacking

    // TODO: Make it patrol when far from player
    // TODO: Make it not leave a certain distance from its spawn point

    // TODO: Now make it again for a dozen different enemies 

    private void Start()
    {
        agent.updateRotation = false;
        agent.updateUpAxis = false;
    }

    void Update()
    {
        target = player.position;
        agent.SetDestination(new Vector3(target.x, target.y, transform.position.z));
    }
}
