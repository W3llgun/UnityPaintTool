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
				foreach (var filter in param.filters)
				{
					if(filter)
					{
						LoopCases(filter, (Vector3 pos, Vector2Int index) => {
							
							color = GetTextureColor(filter, index.x, index.y);
								
							
							if (trueColor)
								Handles.color = color;
							bool check = color.grayscale > permission;
							if (inverseSpawning) check = !check;

							if (check)
								Handles.color = Color.green;
							else
								Handles.color = Color.red;
							//pos *= scaling;
							Handles.CubeCap(4, pos + filter.transform.position, Quaternion.identity, scaling);
						});
					}
				}
			}
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
								if (param.rndRotationY)
									obj.transform.Rotate(Vector3.up, Random.Range(0f, 90f));

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

			size /= scaling;

			float xHalf = (size.x / 2);
			float zHalf = (size.z / 2);

			for (int i = 0; i < size.x; i++)
			{
				for (int j = 0; j < size.z; j++)
				{
					// vec visu
					Vector3 pos = new Vector3((i - xHalf) 
						,size.y 
						,(j - zHalf));

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