Shader "Custom/NewSurfaceShader"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}
        _GlobalSpeed("Global Speed", Float) = 1.0
        _SpecularMap("Specular Map", 2D) = "white" {}
        _NormalMap("Normal Map", 2D) = "bump" {}
        _LightIntensity("Light Intensity", Range(0, 10.0)) = 3.0
        _LightIntensitySpeed("Light Intensity Speed", Float) = 0.3
        _NormalDepth("Normal Depth", Range(0, 1)) = 0.5
        _AmbientOcclusionMap("Ambient Occlusion Map", 2D) = "white" {}
        _AmbientOcclusionStrength("Ambient Occlusion Strength", Float) = 1.0
        _AmbientOcclusionSpeed("Ambient Occlusion Speed", Float) = 0.5
        _EmissionMap("Emission Map", 2D) = "black" {}
        _EmissionStrength("Emission Strength", Float) = 1.0
        _EmissionSpeed("Emission Speed", Float) = 0.5
        _EmissionColor("Emission Color", Color) = (1, 1, 1, 1)
        _WaveSpeed("Wave Speed", Float) = 1.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows

        struct Input
        {
            float2 uv_MainTex;
            float3 viewDir;
        };

        sampler2D _MainTex;
        sampler2D _SpecularMap;
        sampler2D _NormalMap;
        float _GlobalSpeed;
        float _LightIntensity;
        float _LightIntensitySpeed;
        float _NormalDepth;
        sampler2D _AmbientOcclusionMap;
        float _AmbientOcclusionStrength;
        float _AmbientOcclusionSpeed;
        sampler2D _EmissionMap;
        float _EmissionStrength;
        float _EmissionSpeed;
        fixed4 _EmissionColor;
        float _WaveSpeed;

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            // Main Texture
            float mainTexOffset = _Time.y * _GlobalSpeed;
            float2 mainTexUVOffset = float2(mainTexOffset, 0);
            float2 mainTexUV = IN.uv_MainTex + mainTexUVOffset;

            // Apply wave distortion to x-coordinate of texture
            mainTexUV.x += sin(mainTexUV.y * 10 + _Time.y * _WaveSpeed) * 0.05;

            fixed4 mainTexColor = tex2D(_MainTex, mainTexUV);

            // Specular map
            float specularMapOffset = _Time.y * _GlobalSpeed;
            float2 specularMapUVOffset = float2(specularMapOffset, 0);
            fixed4 specularColor = tex2D(_SpecularMap, IN.uv_MainTex + specularMapUVOffset);

            // Normal map
            float normalMapOffset = _Time.y * _GlobalSpeed;
            float2 normalMapUVOffset = float2(normalMapOffset, 0);
            fixed3 normalMap = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex + normalMapUVOffset));
            normalMap.z *= _NormalDepth * 2 - 1;

            // Ambient occlusion
            float ambientOcclusionOffset = _Time.y * _AmbientOcclusionSpeed;
            float2 ambientOcclusionUVOffset = float2(ambientOcclusionOffset, 0);
            float ambientOcclusion = tex2D(_AmbientOcclusionMap, IN.uv_MainTex + ambientOcclusionUVOffset).r;
            ambientOcclusion *= _AmbientOcclusionStrength;

            // Emission map
            float emissionOffset = _Time.y * _EmissionSpeed;
            float2 emissionUVOffset = float2(emissionOffset, 0);
            fixed3 emissionColor = tex2D(_EmissionMap, IN.uv_MainTex + emissionUVOffset).rgb * _EmissionColor.rgb;
            emissionColor *= _EmissionStrength;

            // Light intensity
            float lightIntensity = smoothstep(-1, 1, sin(_Time.y * _LightIntensitySpeed)) * _LightIntensity;

            // Specular map
            o.Metallic = specularColor.r;
            o.Smoothness = specularColor.g;

            // Final output
            o.Albedo = mainTexColor.rgb * (1 - ambientOcclusion);
            o.Normal = normalize(normalMap);
            o.Emission = emissionColor * lightIntensity * ambientOcclusion;
        }
        ENDCG
    }
        FallBack "Diffuse"
}
