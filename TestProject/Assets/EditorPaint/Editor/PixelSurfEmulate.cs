using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class PixelSurfEmulate 
{
	public Texture2D mainTexture;
	public Vector2 textureOffset;
	public bool paintView;
	public bool worldPosition;
	public float tolerance;
	public float scaling = 1;

	public void DisplayGUI()
	{
		mainTexture = (Texture2D)EditorGUILayout.ObjectField("texture", mainTexture, typeof(Texture2D), false);

		if (mainTexture)
		{
			if (!mainTexture.isReadable && GUILayout.Button("Make texture readable"))
			{
				string path = AssetDatabase.GetAssetPath(mainTexture);
				TextureImporter tImporter = AssetImporter.GetAtPath(path) as TextureImporter;
				if (tImporter != null)
				{
					tImporter.textureType = TextureImporterType.Default;

					tImporter.isReadable = true;

					AssetDatabase.ImportAsset(path);
					AssetDatabase.Refresh();
				}
			}
		}
		scaling = EditorGUILayout.FloatField("Scaling", scaling);
		scaling = Mathf.Clamp(scaling, 0.5f, 10);
		textureOffset = EditorGUILayout.Vector2Field("Texture Offset", textureOffset);
		paintView = EditorGUILayout.Toggle("Painting view", paintView);
		float a = tolerance;
		tolerance = EditorGUILayout.Slider("Tolérance", tolerance, 0, 1);
		worldPosition = EditorGUILayout.Toggle("TextureOnWorld", worldPosition);
		if (a != tolerance)
		{
			EditorWindow.GetWindow<SceneView>().Repaint();
		}
	}


	public Color GetTextureColor(MeshFilter filter, int x, int z)
	{
		if (mainTexture && mainTexture.isReadable)
		{
			if (worldPosition)
			{
				Vector3 pos = filter.transform.position;
				pos.x += x;
				pos.z += z;
				return mainTexture.GetPixel((int)pos.x + (int)textureOffset.x, (int)pos.z + (int)textureOffset.y);
			}
			else
			{
				return mainTexture.GetPixel(x + (int)textureOffset.x, z + (int)textureOffset.y);
			}
		}
		return Color.gray;
	}

	Color GetColor(Vector3 position, RaycastHit hit)
	{

		Ray ray = new Ray(position + Vector3.up, -Vector3.up);
		Renderer rend = hit.collider.gameObject.GetComponent<Renderer>();
		MeshCollider meshCollider = hit.collider as MeshCollider;
	
		if (rend == null || rend.sharedMaterial == null || meshCollider == null)
				return Color.gray;

		Texture2D tex = rend.sharedMaterial.GetTexture("_mainTexture") as Texture2D;
		//Texture2D tex = texture as Texture2D;
		Vector2 pixelUV = hit.textureCoord;
		pixelUV *= 0.001f;
		//pixelUV /= 30;
		//pixelUV = new Vector2(Mathf.Round(pixelUV.x), Mathf.Round(pixelUV.y));
		//pixelUV *= 30;

		pixelUV.x *= tex.width;
		pixelUV.y *= tex.height;
		return tex.GetPixel((int)pixelUV.x, (int)pixelUV.y);
	}
}
