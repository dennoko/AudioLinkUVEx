#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace lilToon
{
    public class AudioLinkVUMeterInspector : lilToonInspector
    {
        // Needle properties
        MaterialProperty _NeedleTex;
        MaterialProperty _Pivot;
        MaterialProperty _PivotOffset;
        MaterialProperty _MinAngle;
        MaterialProperty _MaxAngle;
        MaterialProperty _AngleOffset;
        MaterialProperty _AudioLinkBand;
        MaterialProperty _AudioLinkDelay;

        // Red zone emission properties
        MaterialProperty _RedZoneThreshold;
        MaterialProperty _RedZoneColor;

        private static bool isShowVUMeterProperties;
        private const string shaderName = "AudioLinkVUMeter";

        protected override void LoadCustomProperties(MaterialProperty[] props, Material material)
        {
            isCustomShader = true;
            ReplaceToCustomShaders();
            isShowRenderMode = !material.shader.name.Contains("Optional");

            _NeedleTex        = FindProperty("_NeedleTex",        props);
            _Pivot            = FindProperty("_Pivot",            props);
            _PivotOffset      = FindProperty("_PivotOffset",      props);
            _MinAngle         = FindProperty("_MinAngle",         props);
            _MaxAngle         = FindProperty("_MaxAngle",         props);
            _AngleOffset      = FindProperty("_AngleOffset",      props);
            _AudioLinkBand    = FindProperty("_AudioLinkBand",    props);
            _AudioLinkDelay   = FindProperty("_AudioLinkDelay",   props);
            _RedZoneThreshold = FindProperty("_RedZoneThreshold", props);
            _RedZoneColor     = FindProperty("_RedZoneColor",     props);
        }

        protected override void DrawCustomProperties(Material material)
        {
            isShowVUMeterProperties = Foldout("VU Meter Needle", "VU Meter Needle", isShowVUMeterProperties);
            if (isShowVUMeterProperties)
            {
                EditorGUILayout.BeginVertical(boxOuter);
                EditorGUILayout.LabelField("VU Meter Needle", customToggleFont);
                EditorGUILayout.BeginVertical(boxInnerHalf);

                m_MaterialEditor.TexturePropertySingleLine(
                    new GUIContent("Needle Mask", "White = needle, Black = transparent"),
                    _NeedleTex);
                m_MaterialEditor.ShaderProperty(_Pivot,            "Pivot (UV)");
                m_MaterialEditor.ShaderProperty(_PivotOffset,      "Pivot Offset (UV)");
                m_MaterialEditor.ShaderProperty(_MinAngle,         "Min Angle (deg)");
                m_MaterialEditor.ShaderProperty(_MaxAngle,         "Max Angle (deg)");
                m_MaterialEditor.ShaderProperty(_AngleOffset,      "Angle Offset (deg)");

                DrawLine();

                m_MaterialEditor.ShaderProperty(_AudioLinkBand,    "AudioLink Band");
                m_MaterialEditor.ShaderProperty(_AudioLinkDelay,   "AudioLink Delay");

                DrawLine();

                m_MaterialEditor.ShaderProperty(_RedZoneThreshold, "Red Zone Threshold");
                m_MaterialEditor.ShaderProperty(_RedZoneColor,     "Red Zone Emission Color");

                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();
            }
        }

        protected override void ReplaceToCustomShaders()
        {
            lts         = Shader.Find(shaderName + "/lilToon");
            ltsc        = Shader.Find("Hidden/" + shaderName + "/Cutout");
            ltst        = Shader.Find("Hidden/" + shaderName + "/Transparent");
            ltsot       = Shader.Find("Hidden/" + shaderName + "/OnePassTransparent");
            ltstt       = Shader.Find("Hidden/" + shaderName + "/TwoPassTransparent");

            ltso        = Shader.Find("Hidden/" + shaderName + "/OpaqueOutline");
            ltsco       = Shader.Find("Hidden/" + shaderName + "/CutoutOutline");
            ltsto       = Shader.Find("Hidden/" + shaderName + "/TransparentOutline");
            ltsoto      = Shader.Find("Hidden/" + shaderName + "/OnePassTransparentOutline");
            ltstto      = Shader.Find("Hidden/" + shaderName + "/TwoPassTransparentOutline");

            ltsoo       = Shader.Find(shaderName + "/[Optional] OutlineOnly/Opaque");
            ltscoo      = Shader.Find(shaderName + "/[Optional] OutlineOnly/Cutout");
            ltstoo      = Shader.Find(shaderName + "/[Optional] OutlineOnly/Transparent");

            ltstess     = Shader.Find("Hidden/" + shaderName + "/Tessellation/Opaque");
            ltstessc    = Shader.Find("Hidden/" + shaderName + "/Tessellation/Cutout");
            ltstesst    = Shader.Find("Hidden/" + shaderName + "/Tessellation/Transparent");
            ltstessot   = Shader.Find("Hidden/" + shaderName + "/Tessellation/OnePassTransparent");
            ltstesstt   = Shader.Find("Hidden/" + shaderName + "/Tessellation/TwoPassTransparent");

            ltstesso    = Shader.Find("Hidden/" + shaderName + "/Tessellation/OpaqueOutline");
            ltstessco   = Shader.Find("Hidden/" + shaderName + "/Tessellation/CutoutOutline");
            ltstessto   = Shader.Find("Hidden/" + shaderName + "/Tessellation/TransparentOutline");
            ltstessoto  = Shader.Find("Hidden/" + shaderName + "/Tessellation/OnePassTransparentOutline");
            ltstesstto  = Shader.Find("Hidden/" + shaderName + "/Tessellation/TwoPassTransparentOutline");

            ltsl        = Shader.Find(shaderName + "/lilToonLite");
            ltslc       = Shader.Find("Hidden/" + shaderName + "/Lite/Cutout");
            ltslt       = Shader.Find("Hidden/" + shaderName + "/Lite/Transparent");
            ltslot      = Shader.Find("Hidden/" + shaderName + "/Lite/OnePassTransparent");
            ltsltt      = Shader.Find("Hidden/" + shaderName + "/Lite/TwoPassTransparent");

            ltslo       = Shader.Find("Hidden/" + shaderName + "/Lite/OpaqueOutline");
            ltslco      = Shader.Find("Hidden/" + shaderName + "/Lite/CutoutOutline");
            ltslto      = Shader.Find("Hidden/" + shaderName + "/Lite/TransparentOutline");
            ltsloto     = Shader.Find("Hidden/" + shaderName + "/Lite/OnePassTransparentOutline");
            ltsltto     = Shader.Find("Hidden/" + shaderName + "/Lite/TwoPassTransparentOutline");

            ltsref      = Shader.Find("Hidden/" + shaderName + "/Refraction");
            ltsrefb     = Shader.Find("Hidden/" + shaderName + "/RefractionBlur");
            ltsfur      = Shader.Find("Hidden/" + shaderName + "/Fur");
            ltsfurc     = Shader.Find("Hidden/" + shaderName + "/FurCutout");
            ltsfurtwo   = Shader.Find("Hidden/" + shaderName + "/FurTwoPass");
            ltsfuro     = Shader.Find(shaderName + "/[Optional] FurOnly/Transparent");
            ltsfuroc    = Shader.Find(shaderName + "/[Optional] FurOnly/Cutout");
            ltsfurotwo  = Shader.Find(shaderName + "/[Optional] FurOnly/TwoPass");
            ltsgem      = Shader.Find("Hidden/" + shaderName + "/Gem");
            ltsfs       = Shader.Find(shaderName + "/[Optional] FakeShadow");

            ltsover     = Shader.Find(shaderName + "/[Optional] Overlay");
            ltsoover    = Shader.Find(shaderName + "/[Optional] OverlayOnePass");
            ltslover    = Shader.Find(shaderName + "/[Optional] LiteOverlay");
            ltsloover   = Shader.Find(shaderName + "/[Optional] LiteOverlayOnePass");

            ltsm        = Shader.Find(shaderName + "/lilToonMulti");
            ltsmo       = Shader.Find("Hidden/" + shaderName + "/MultiOutline");
            ltsmref     = Shader.Find("Hidden/" + shaderName + "/MultiRefraction");
            ltsmfur     = Shader.Find("Hidden/" + shaderName + "/MultiFur");
            ltsmgem     = Shader.Find("Hidden/" + shaderName + "/MultiGem");
        }
    }
}
#endif
