using UnityEngine.SceneManagement;
using UnityEngine;


public class ResetSceneUIButton : MonoBehaviour
{
    public void ResetScene()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().name);
    }    
}
