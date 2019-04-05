using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace EditorSpace
{ 
	public partial class EditorPaint : EditorWindow
	{
		//MeshRenderer objectScene;
		PixelSurfEmulate shader;

		
		List<GameObject> spawned = new List<GameObject>();
		public bool visualisation;
		
		
		bool inverseSpawning;
		bool inverseZY ;


		
		void SpawnerTab()
		{
			//DrawObjectRect();
			//DrawTextureRect();
			if (param.filters.Count > 0 && shader.mainTexture && GUILayout.Button("Spawn"))
			{
				Spawn();
			}
			EditorGUILayout.LabelField("Spawner");
			DisplayMeshesSelected();

			shader.DisplayGUI();

			visualisation = EditorGUILayout.Toggle("Visualisation", visualisation);
			
			
			inverseSpawning = EditorGUILayout.Toggle("Inversed Spawn", inverseSpawning);
			inverseZY = EditorGUILayout.Toggle("Inversed X & Y", inverseZY);
			
			prefabListGUI();
		}
		
		void DrawingSceneSpawner()
		{
			if (visualisation && currentEvent.type == EventType.Repaint && param.filters.Count > 0)
			{
				Color color = Color.gray;
				MeshFilter filter;
				for (int i = 0; i < param.filters.Count ; i++)
				{
					filter = param.filters[i];
					if (filter)
					{
						LoopCases(filter, (Vector3 pos, Vector2Int index) => {
							
							color = shader.GetTextureColor(filter, index.x, index.y);
								
							bool check = color.grayscale > shader.tolerance;
							if (inverseSpawning) check = !check;

							if (!shader.paintView)
								Handles.color = color;
							else if (check)
								Handles.color = Color.green;
							else
								Handles.color = Color.red;
							//pos *= scaling;
							//ApplyShaderToTerrain(filter, pos + filter.transform.position, scaling);
							//Handles.CubeCap(4, pos + filter.transform.position, Quaternion.identity, scaling);
							Handles.CubeHandleCap(
								0,
								pos + filter.transform.position - (filter.transform.up * shader.scaling),
								Quaternion.identity,
								shader.scaling,
								EventType.Repaint
							);
						});
					}
				}
			}
			//if (param.filters.Count > 0 && param.filters[0] != null)
			//Graphics.Blit(texture, rendTexture, param.filters[0].GetComponent<Renderer>().material);
		}

		void ApplyShaderToTerrain(MeshFilter filter, Vector3 pos, float size)
		{
			
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
						Color color = shader.GetTextureColor(filter, index.x, index.y);
						bool check = color.grayscale > shader.tolerance;
						if (inverseSpawning) check = !check;

						if (check)
						{
							if (param.randomPosition)
							{
								pos.x += Random.Range(shader.scaling / 2 * -1, shader.scaling / 2);
								pos.z += Random.Range(shader.scaling / 2 * -1, shader.scaling / 2);
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

			size /= shader.scaling;

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

					pos *= shader.scaling ;
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