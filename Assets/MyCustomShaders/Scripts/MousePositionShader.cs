using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public class MousePositionShader : MonoBehaviour
{
    public List<string> _ShaderVarList; //"_MousePos";

    private void Update()
    {
        Plane p = new Plane(Vector3.up, Vector3.zero);
        Vector2 mousePos = Input.mousePosition;
        Ray ray = GetComponent<Camera>().ScreenPointToRay(mousePos);
        if (p.Raycast(ray, out float enterDist))
        {
            Vector3 worldMousePos = ray.GetPoint(enterDist);

            foreach (string shaderVar in _ShaderVarList)
            {
                Shader.SetGlobalVector(shaderVar, worldMousePos);
            }            
        }
    }
}
