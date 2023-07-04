using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Blurs : MonoBehaviour
{
    public Material PPMotionBlurMat;
    public Material PPRadialBlurMat;
    public Material PPBoxBlur;
    public Material PPGaussianBlur;
    public Material PPDirectionalBlur;
    public Material PPBokehBlur;
    public BlurType blurType;
    public enum BlurType
    {
        None,
        RadialBlur,
        GaussianBlur,
        BoxBlur,
        MotionBlur,
        DirectionalBlur,
        BokehBlur
    }

    public BokehType bokehType;
    public enum BokehType
    {
        Circular,
        Star
    }
    static public Camera cam;

    [HideInInspector]
    static Vector3 PreUpdatePos;
    static Matrix4x4 previousViewProjection;
    static Matrix4x4 previousInvProjection;
    static Matrix4x4 previousCameraToWorld;
    private void OnEnable()
    {
        cam = GetComponent<Camera>();
    }
    private void Start()
    {
        cam.depthTextureMode = DepthTextureMode.Depth;
    }

    public static void PreUpdate(Vector3 pos)
    {
        previousViewProjection = cam.projectionMatrix * cam.worldToCameraMatrix;
        previousInvProjection = Matrix4x4.Inverse(cam.projectionMatrix);
        previousCameraToWorld = cam.cameraToWorldMatrix;
        PreUpdatePos = pos;
    }
    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        //-----------None----------
        Graphics.Blit(src, dest);

        //---------Motion Blur------------
        Matrix4x4 ViewProjection = cam.projectionMatrix * cam.worldToCameraMatrix;
        Matrix4x4 InvViewProjection = Matrix4x4.Inverse(ViewProjection);
        PPMotionBlurMat.SetMatrix("_PreviousCameraToWorld", previousCameraToWorld);
        PPMotionBlurMat.SetMatrix("_PreviousInvProjection", previousInvProjection);
        PPMotionBlurMat.SetMatrix("_PreviousViewProjection", previousViewProjection);
        PPMotionBlurMat.SetMatrix("_ViewProjection", ViewProjection);
        PPMotionBlurMat.SetMatrix("_InvViewProjection", InvViewProjection);

        PPMotionBlurMat.SetVector("_PreviousWorldSpaceCameraPos", PreUpdatePos);
        if (blurType == BlurType.MotionBlur)
            Graphics.Blit(src, dest, PPMotionBlurMat);

        //----------Radial Blur-------------
        if (blurType == BlurType.RadialBlur)
            Graphics.Blit(src, dest, PPRadialBlurMat);

        //------------Box Blur--------------
        if (blurType == BlurType.BoxBlur)
            Graphics.Blit(src, dest, PPBoxBlur);

        //----------Gaussian Blur-----------
        if (blurType == BlurType.GaussianBlur)
            Graphics.Blit(src, dest, PPGaussianBlur);

        //---------Directional Blur---------
        if (blurType == BlurType.DirectionalBlur)
            Graphics.Blit(src, dest, PPDirectionalBlur);

        //------------Bokeh Blur------------
        if (blurType == BlurType.BokehBlur)
        {
            PPBokehBlur.SetInt("_BokehType", (int)bokehType);
            Graphics.Blit(src, dest, PPBokehBlur);
        }
    }
}

