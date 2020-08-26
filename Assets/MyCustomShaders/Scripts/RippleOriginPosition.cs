using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RippleOriginPosition : MonoBehaviour
{
    void Update()
    {
        Shader.SetGlobalVector("_RippleOrigin", transform.position);
    }
}
