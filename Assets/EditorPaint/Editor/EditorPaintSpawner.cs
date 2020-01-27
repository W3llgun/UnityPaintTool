using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorSpace
{ 
	public partial class EditorPaint : EditorWindow
	{
		//MeshRenderer objectScene;
		Texture2D texture;
		float scaling = 1;
		List<GameObject> spawned = new List<GameObject>();
		public bool visualisation;
		public bool trueColor;
		Vector2 textureOffset;
		float permission;
		bool inverseSpawning;
		bool inverseZY ;

		void SpawnerTab()
		{
			//DrawObjectRect();
			//DrawTextureRect();
			if (param.filters.Count > 0 && texture && GUILayout.Button("Spawn"))
			{
				Spawn();
			}
			EditorGUILayout.LabelField("Spawner");
			DisplayMeshesSelected();
			texture = (Texture2D)EditorGUILayout.ObjectField("texture", texture, typeof(Texture2D), false);
			if(texture)
			{
				if(!texture.isReadable && GUILayout.Button("Make texture readable"))
				{
					string path = AssetDatabase.GetAssetPath(texture);
					TextureImporter tImporter = AssetImporter.GetAtPath(path) as TextureImporter;
					if (tImporter != null)
					{
						tImporter.textureType = TextureImporterType.Default;

						tImporter.isReadable = true;

						AssetDatabase.ImportAsset(path);
						AssetDatabase.Refresh();
					}
				}
				textureOffset = EditorGUILayout.Vector2Field("Texture Offset", textureOffset);
			}
			scaling = EditorGUILayout.FloatField("Scaling", scaling);
			scaling = Mathf.Clamp(scaling, 0.5f, 10);
			visualisation = EditorGUILayout.Toggle("Visualisation", visualisation);
			trueColor = EditorGUILayout.Toggle("TrueColor", trueColor);
			param.worldPositionTexture = EditorGUILayout.Toggle("TextureOnWorld", param.worldPositionTexture);
			inverseSpawning = EditorGUILayout.Toggle("Inversed Spawn", inverseSpawning);
			inverseZY = EditorGUILayout.Toggle("Inversed X & Y", inverseZY);
			float a = permission;
			permission = EditorGUILayout.Slider("Tolérance", permission, 0,1);
			if(a != permission)
			{
				EditorWindow.GetWindow<SceneView>().Repaint();
			}

			
			prefabListGUI();
		}
		
		void DrawingSceneSpawner()
		{
			if (visualisation && param.filters.Count > 0)
			{
				Color color = Color.gray;
				MeshFilter filter;
				for (int i = 0; i < param.filters.Count ; i++)
				{
					filter = param.filters[i];
					if (filter)
					{
						LoopCases(filter, (Vector3 pos, Vector2Int index) => {
							
							color = GetTextureColor(filter, index.x, index.y);
								
							bool check = color.grayscale > permission;
							if (inverseSpawning) check = !check;

							if (trueColor)
								Handles.color = color;
							else if (check)
								Handles.color = Color.green;
							else
								Handles.color = Color.red;
							//pos *= scaling;
							//ApplyShaderToTerrain(filter, pos + filter.transform.position, scaling);
							Handles.CubeCap(4, pos + filter.transform.position, Quaternion.identity, scaling);
						});
					}
				}
			}
		}

		void ApplyShaderToTerrain(MeshFilter filter, Vector3 pos, float size)
		{

		}

		Color GetTextureColor(MeshFilter filter, int x, int z)
		{
			if (texture && texture.isReadable)
			{
				if (param.worldPositionTexture)
				{
					Vector3 pos = filter.transform.position;
					pos.x += x;
					pos.z += z;
					return texture.GetPixel((int)pos.x + (int)textureOffset.x, (int)pos.z + (int)textureOffset.y);
				}
				else
				{
					return texture.GetPixel(x + (int)textureOffset.x, z + (int)textureOffset.y);
				}
			}
			return Color.gray;
		}

		void Spawn()
		{
			visualisation = false;
			Reset();
			InitRootGameObject();

			foreach (var filter in param.filters)
			{
				if(filter)
				{
					LoopCases(filter, (Vector3 pos, Vector2Int index) => {
						Color color = GetTextureColor(filter, index.x, index.y);
						bool check = color.grayscale > permission;
						if (inverseSpawning) check = !check;

						if (check)
						{
							if (param.randomPosition)
							{
								pos.x += Random.Range(scaling / 2 * -1, scaling / 2);
								pos.z += Random.Range(scaling / 2 * -1, scaling / 2);
							}

							GameObject obj = SpawnObject(pos + filter.transform.position);
							if (obj)
							{
								obj.transform.up = Vector3.up;

								obj.transform.Rotate(Vector3.right, Random.Range(0, param.rotationOffset.x));
								obj.transform.Rotate(Vector3.up, Random.Range(0, param.rotationOffset.y));
								obj.transform.Rotate(Vector3.forward, Random.Range(0, param.rotationOffset.z));

								spawned.Add(obj);
							}
						}
					});
				}
			}
		}
		

		void LoopCases(MeshFilter filter, System.Action<Vector3, Vector2Int> action)
		{
			Vector3 size = new Vector3(filter.sharedMesh.bounds.size.x * filter.transform.localScale.x
				, filter.sharedMesh.bounds.size.y * filter.transform.localScale.y
				, filter.sharedMesh.bounds.size.z * filter.transform.localScale.z);

			if(inverseZY)
			{
				float y = size.y;
				size.y = size.z;
				size.z = y;
			}

			size /= scaling;

			float width = (size.x / 2);
			float length = (size.z / 2);
			Vector3 pos;

			for (int i = 0; i < size.x; i++)
			{
				for (int j = 0; j < size.z; j++)
				{
					pos = new Vector3((i - width) 
						,size.y 
						,(j - length));

					pos *= scaling ;
					action.Invoke(pos, new Vector2Int(i, j));
				}
			}
		}


		void Reset()
		{
			if (spawned == null)
			{
				spawned = new List<GameObject>();
				return;
			}
			for (int i = 0; i < spawned.Count; i++)
			{
				if(spawned[i])
				{
					DestroyImmediate(spawned[i]);
				}
			}
			spawned.Clear();
		}
	}
}