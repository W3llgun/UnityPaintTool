using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using Edit = EditorSpace.EditorImprovement;

namespace EditorSpace
{
	/*
     *  TODO : SPAWN LOGIC / PROCEDURAL & SMART SPAWN WITH WEIGHT PROBABILITY
     *  BUG:  - Ctrl-Z discard all
     *			- Multiple object always spawn with the same rotation as the first one
     */

	public enum PaintMode
    {
        Auto = 1,
        Forced = 2,
        Snap = 3,
    }

    [System.Serializable]
    public class PaintParam
    {
        const string SERIALIZED_NAME = "PaintToolParam";
        
        [SerializeField]
        public float size = 2;
        [SerializeField]
        public int density = 2;
        [SerializeField]
        public bool rndRotationX = false;
        [SerializeField]
        public bool rndRotationY = false;
        [SerializeField]
        public bool rndRotationZ = false;
        [SerializeField]
        public bool proximityCheck = false;
        [SerializeField]
        public float proximityDistance = 1;
        [SerializeField]
        public float maxYPosition = 10;
        [SerializeField]
        public PaintMode mode = PaintMode.Snap;
        [SerializeField]
        public float heightForced = 0;
        [SerializeField]
        public int listSize = 0;
        [SerializeField]
        public LayerMask paintMask = 1;
        [SerializeField]
        public bool addPrefabNameToGroup = true, gizmoCircle = true, gizmoHeight, gizmoSize = true, gizmoDensity = true, gizmoLayer, gizmoName, gizmoPosition, gizmoNormal, editorPrefabVisual = true;
        [SerializeField]
        public List<PaintObject> objects;
        
        public static void Save(PaintParam param, string path)
        {
            string filePath = Path.Combine(path, SERIALIZED_NAME);
            if (File.Exists(filePath)) File.Delete(filePath);
            File.WriteAllText(filePath, EditorJsonUtility.ToJson(param));
        }

        public static void Load(PaintParam param, string path)
        {
            string filePath = Path.Combine(path, SERIALIZED_NAME);
            if (File.Exists(filePath))
            {
                EditorJsonUtility.FromJsonOverwrite(File.ReadAllText(filePath), param);
            }
        }
    }

    [System.Serializable]
    public class PaintObject
    {
        
        [SerializeField]
        public GameObject prefab = null;
        [SerializeField]
        public string customName = "";
        [SerializeField]
        public Vector2 scale = Vector2.one;

        public bool isDisplayed = true;

        public static void display(PaintObject obj, bool displayVisual)
        {
            if (obj == null) return;
            Edit.Column(() =>
            {
                obj.isDisplayed = EditorGUILayout.Foldout(obj.isDisplayed, obj.prefab ? obj.prefab.name : "Empty", true);
                if (obj.isDisplayed)
                {
                    Edit.Row(() =>
                    {
                        Edit.Indent(() =>
                        {
                            if (displayVisual) GUILayout.Label(AssetPreview.GetAssetPreview(obj.prefab));
                            Edit.Column(() => 
                            {
                                obj.prefab = (GameObject)EditorGUILayout.ObjectField("Prefab",obj.prefab, typeof(GameObject), true);
                                if (obj.prefab != null)
                                {
                                    if (obj.customName.Length == 0 && obj.prefab) obj.customName = obj.prefab.name;
                                    obj.customName = EditorGUILayout.TextField("Name", obj.customName);
                                    obj.scale = EditorGUILayout.Vector2Field("Scale Modifier (Min/Max) :", obj.scale);
                                }

                            });
                        }, 1);
                    });
                }
            });
        }
    }

    /// <summary>
    /// Editor tool for creating(painting) groups of gameobjects like forest or jungle
    /// </summary>
    public class EditorPaint : EditorWindow
    {
        string SERIALIZED_PATH;
        string ROOT_PARENT_NAME = "Paint";
        string GROUP_NAME = "Group_";
        string TEMPORARY_OBJECT_NAME = "PaintTemporary";

        #region variables
        // Displayed Variables
        [SerializeField]
        public PaintParam param;

        // Private
        Vector3 currentMousePos = Vector3.zero;
        Vector3 lastPaintPos = Vector3.zero;
        Vector2 scrollView = Vector2.zero;
        List<List<GameObject>> memory;
        List<GameObject> groups;
        GameObject rootParent = null;
        Transform paintPosition;
        bool enableSceneGizmo = true;
        bool toggleGroupKeys, toggleGroupGizmo, toggleGroupEditor, togglePrefabs = true;
        bool isPainting = false;
        int paintNumber = 0;
        int windowsTab = 0;
        
        Event currentEvent;
        RaycastHit mouseHitPoint;
        List<string> layerNames;
        
        #endregion

        #region Unity
        [MenuItem("Tools/EditorPaint")]
        public static void ShowWindow()
        {
            EditorWindow.GetWindow(typeof(EditorPaint));
        }

        /// <summary>
        /// Called on start
        /// </summary>
        void OnEnable()
        {
            SERIALIZED_PATH = Application.persistentDataPath;
            param = new PaintParam();
            PaintParam.Load(param, SERIALIZED_PATH);
            SceneView.onSceneGUIDelegate += SceneGUI;
            if (param.objects == null)
                param.objects = new List<PaintObject>();
            layerNames = new List<string>();
            int count = 0;
            for(int i =0; i <= 31; i++)
            {
                layerNames.Add(LayerMask.LayerToName(i));
                count++;
            }
        }

        void OnDisable()
        {
            PaintParam.Save(param, SERIALIZED_PATH);
            SceneView.onSceneGUIDelegate -= SceneGUI;
            if(paintPosition) DestroyImmediate(paintPosition.gameObject);
        }
        #endregion

        #region Clear
        void clearMemory()
        {
            if (memory != null)
            {
                foreach (var list in memory)
                {
                    //if (list[0]) DestroyImmediate(list[0].transform.parent.gameObject);
                    list.Clear();
                }
                memory.Clear();
                paintNumber = 0;
            }
            else
            {
                memory = new List<List<GameObject>>();
            }
            GameObject obj;
            while ((obj = GameObject.Find(TEMPORARY_OBJECT_NAME)) != null)
            {
                DestroyImmediate(obj);
            }
        }

        #endregion
        
        #region EditorGUI
        void OnGUI()
        {
            Edit.Row(() => {
                windowsTab = GUILayout.SelectionGrid(windowsTab, new string[] { "Paint", "Setting" }, 2, EditorStyles.toolbarButton);
                if(GUILayout.Button("Exit", EditorStyles.toolbarButton, GUILayout.Width(50)))
                {
                    this.Close();
                }
            });
            Edit.View(ref scrollView, () => {
                dropArea(new Rect(0,0, this.position.width, this.position.height));
                if (windowsTab == 1)
                {
                    optionTab();
                }
                else if (windowsTab == 0)
                {
                    float tempSize = param.size;
                    int tempDensity = param.density;
                    paintTab();
                    prefabListGUI();
                    datacheck(tempSize, tempDensity);
                }
            });
        }

        void dropArea(Rect rct)
        {
            Event evt = Event.current;
            if (rct.Contains(evt.mousePosition))
            {
                DragAndDrop.visualMode = DragAndDropVisualMode.Copy;

                if (evt.type == EventType.DragPerform)
                {

                    DragAndDrop.AcceptDrag();
                    foreach (Object dragged_object in DragAndDrop.objectReferences)
                    {
                        if (dragged_object.GetType() == typeof(GameObject))
                            objectToList(dragged_object as GameObject);
                    }

                }
            }
        }

        void objectToList(GameObject obj)
        {
            if(obj)
            {
                foreach (var paintObj in param.objects)
                {
                    if(paintObj.prefab == null)
                    {
                        paintObj.prefab = obj;
                        return;
                    }
                }
                param.listSize++;
                PaintObject paint = new PaintObject();
                paint.prefab = obj;
                param.objects.Add(paint);
            }
        }

        void optionTab()
        {
            toggleGroupKeys = Edit.ToggleGroup(toggleGroupKeys, "hotKey", 1,() =>
            {
                EditorGUILayout.LabelField("ctrl + click : Paint");
                EditorGUILayout.LabelField("ctrl + scroll : Change Size");
                EditorGUILayout.LabelField("alt + scroll : Change Density");
                EditorGUILayout.LabelField("ctrl + alt + Z : Cancel Paint");
                EditorGUILayout.LabelField("ctrl + alt + Click : Current height as Forced height");
            }, "Box");
            toggleGroupGizmo = Edit.ToggleGroup(toggleGroupGizmo, "Gizmo", 1,() =>
            {
                enableSceneGizmo = EditorGUILayout.Toggle(new GUIContent("Display Gizmo", "Display the scene UI"), enableSceneGizmo);
                if (enableSceneGizmo)
                {
                    EditorGUILayout.LabelField("", GUI.skin.horizontalSlider);

                    param.gizmoSize = EditorGUILayout.Toggle(new GUIContent("Size", ""), param.gizmoSize);
                    param.gizmoDensity = EditorGUILayout.Toggle(new GUIContent("Density", ""), param.gizmoDensity);
                    param.gizmoHeight = EditorGUILayout.Toggle(new GUIContent("Height", ""), param.gizmoHeight);
                    param.gizmoLayer = EditorGUILayout.Toggle(new GUIContent("Layer", ""), param.gizmoLayer);
                    param.gizmoName = EditorGUILayout.Toggle(new GUIContent("Name", ""), param.gizmoName);
                    param.gizmoPosition = EditorGUILayout.Toggle(new GUIContent("Position", ""), param.gizmoPosition);
                    param.gizmoCircle = EditorGUILayout.Toggle(new GUIContent("Circle", ""), param.gizmoCircle);
                    Edit.Row(() =>
                    {
                        param.gizmoNormal = EditorGUILayout.Toggle(new GUIContent("Normal", ""), param.gizmoNormal);
                        if (param.gizmoNormal)
                        {
                            gizmoNormalLenght = EditorGUILayout.FloatField(new GUIContent("Lenght", ""), gizmoNormalLenght);
                        }
                    });
                }
            }, "Box");
            toggleGroupEditor = Edit.ToggleGroup(toggleGroupEditor, "Editor", 1, () =>
            {
                ROOT_PARENT_NAME = EditorGUILayout.TextField("Root Parent Name:", ROOT_PARENT_NAME);
                GROUP_NAME = EditorGUILayout.TextField("Group Name:", GROUP_NAME);
                param.addPrefabNameToGroup = EditorGUILayout.Toggle("Add prefab name to group", param.addPrefabNameToGroup);
                param.editorPrefabVisual = EditorGUILayout.Toggle(new GUIContent("Show Prefab Preview", ""), param.editorPrefabVisual);
                Edit.Row(() =>
                {
                    EditorGUILayout.LabelField("Clear Data:");
                    if (GUILayout.Button("Prefab list", EditorStyles.miniButtonLeft))
                    {
                        param.listSize = 0;
                        param.objects.Clear();
                    }
                    if (GUILayout.Button("Paint history", EditorStyles.miniButtonRight))
                    {
                        clearMemory();
                    }
                });                
            }, "Box");
            
        }
        
        float gizmoNormalLenght = 1;
        void paintTab()
        {
            Edit.Column(() =>
            {
                param.paintMask = EditorGUILayout.MaskField(new GUIContent("Paint Layer","on which layer the tool will paint"), param.paintMask, layerNames.ToArray());
                param.size = EditorGUILayout.FloatField("Size :", param.size);
                param.density = EditorGUILayout.IntField("Density :", param.density);
                Edit.Row(() =>
                {
                    GUILayout.Label("Random Rotation :");
                    param.rndRotationX = GUILayout.Toggle(param.rndRotationX, "X");
                    param.rndRotationY = GUILayout.Toggle(param.rndRotationY, "Y");
                    param.rndRotationZ = GUILayout.Toggle(param.rndRotationZ, "Z");
                });
                Edit.Row(() =>
                {
                    param.proximityCheck = EditorGUILayout.Toggle("Proximity Check ", param.proximityCheck);
                    if (param.proximityCheck) param.proximityDistance = EditorGUILayout.Slider(param.proximityDistance, 0.1f, param.size);
                });
                Edit.Row(() =>
                {
                    EditorGUILayout.LabelField("Mode");
                    if (GUILayout.Toggle(param.mode == PaintMode.Auto, "Default", EditorStyles.miniButtonLeft, GUILayout.MaxWidth(100))) param.mode = PaintMode.Auto;
                    if (GUILayout.Toggle(param.mode == PaintMode.Forced, "Y-Forced", EditorStyles.miniButtonMid, GUILayout.MaxWidth(100))) param.mode = PaintMode.Forced;
                    if (GUILayout.Toggle(param.mode == PaintMode.Snap, "Snap", EditorStyles.miniButtonRight, GUILayout.MaxWidth(100))) param.mode = PaintMode.Snap;
                    GUILayout.FlexibleSpace();
                });
                if (param.mode == PaintMode.Auto)
                {
                    EditorGUILayout.LabelField("Use the mouse position");
                }
                else if (param.mode == PaintMode.Forced)
                {
                    param.heightForced = EditorGUILayout.FloatField("Forced height :", param.heightForced);
                }
                else if (param.mode == PaintMode.Snap)
                {
                    Edit.Column(() =>
                    {
                        param.maxYPosition = EditorGUILayout.FloatField(new GUIContent("Roof height", "Define the max height needed for the object to spawn"), param.maxYPosition);
                    });
                }
            },"Box");
        }

        void prefabListGUI()
        {
            Edit.Column(() =>
            {
                Edit.Row(() =>
                {
                    param.listSize = EditorGUILayout.IntField("Count: ", param.listSize);
                    if (GUILayout.Button(" + ")) param.listSize++;
                    if (GUILayout.Button(" - ")) param.listSize--;
                });
                param.listSize = Mathf.Max(0, param.listSize);
                togglePrefabs = Edit.ToggleGroup(togglePrefabs, "Prefabs", 0,() => {
                    for (int i = 0; i < param.objects.Count; i++)
                    {
                        Edit.Row(() =>
                        {
                            PaintObject.display(param.objects[i], param.editorPrefabVisual);
                        }, "Box");
                    }
                });
            }, "Box");
            GUILayout.Space(10);
        }

        void datacheck(float tempSize, int tempDensity)
        {
            if (tempSize != param.size)
            {
                param.size = Mathf.Max(param.size, 1);
                SceneView.RepaintAll();
            }
            else if (param.density != tempDensity)
            {
                param.density = Mathf.Max(param.density, 1);
            }
            else if (param.objects != null && param.listSize != param.objects.Count)
            {
                List<PaintObject> tempObj = new List<PaintObject>(param.listSize);
                for (int i = 0; i < param.listSize; i++)
                {
                    if (param.objects.Count > i)
                        tempObj.Add(param.objects[i]);
                    else
                        tempObj.Add(new PaintObject());
                }
                param.objects = new List<PaintObject>(tempObj);
            }
        }
        
        #endregion

        #region SceneGUI
        /// <summary>
        /// The function called each frame ( == Update)
        /// </summary>
        void SceneGUI(SceneView sceneView)
        {
            currentEvent = Event.current;
            updateMousePos(sceneView);
            drawGizmo();
            sceneInput();

            // refresh the scene when mouse move
            if (Event.current.type == EventType.MouseMove || Event.current.type == EventType.MouseDrag) SceneView.RepaintAll();
        }

        /// <summary>
        /// Draw a circle around the mouse showing the zone of painting
        /// </summary>
        void drawGizmo()
        {
            if (!enableSceneGizmo) return;
            if (isPainting)
                Handles.color = Color.red;
            else
                Handles.color = Color.green;
            Vector3 pos = currentMousePos;
            //rotate = Quaternion.AngleAxis(90, mouseHitPoint.normal) * Quaternion.AngleAxis(90, Vector3.right);

            if (mouseHitPoint.transform)
            {
                if (paintPosition == null) paintPosition = new GameObject(TEMPORARY_OBJECT_NAME).transform;

                paintPosition.rotation = mouseHitPoint.transform.rotation;
                paintPosition.forward = mouseHitPoint.normal;
                if (param.mode == PaintMode.Forced) pos.y = param.heightForced;
                if (param.gizmoNormal) Handles.ArrowCap(3, mouseHitPoint.point, paintPosition.rotation, gizmoNormalLenght);
                if (param.gizmoCircle) Handles.CircleCap(2, currentMousePos, paintPosition.rotation, param.size);
                paintPosition.up = mouseHitPoint.normal;
            }
            
            Handles.BeginGUI();
            GUIStyle style = new GUIStyle();
            style.normal.textColor = Color.black;
            GUILayout.BeginArea(new Rect(currentEvent.mousePosition.x + 10, currentEvent.mousePosition.y + 10, 250, 100));
            if (param.gizmoSize) GUILayout.TextField("Size " + param.size, style);
            if (param.gizmoDensity) GUILayout.TextField("Density " + param.density, style);
            if (param.gizmoHeight) GUILayout.TextField("Height " + currentMousePos.y, style);
            if (param.gizmoLayer) GUILayout.TextField("Layer " + (mouseHitPoint.collider ? LayerMask.LayerToName(mouseHitPoint.collider.gameObject.layer) : "none"), style);
            if (param.gizmoName) GUILayout.TextField("Name " + (mouseHitPoint.collider ? mouseHitPoint.collider.name : "none"), style);
            if (param.gizmoPosition) GUILayout.TextField("Position " + currentMousePos.ToString(), style);
           
            if (param.mode == PaintMode.Forced)
                GUILayout.TextField("Force-Height " + param.heightForced, style);
            GUILayout.EndArea();
            Handles.EndGUI();

        }

        /// <summary>
        /// Update the current mouse position
        /// </summary>
        void updateMousePos(SceneView sceneView)
        {
            if(currentEvent.control) HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));    // disable selection rectangle
            RaycastHit hit;
            Ray ray = sceneView.camera.ScreenPointToRay(new Vector2(currentEvent.mousePosition.x, sceneView.camera.pixelHeight - currentEvent.mousePosition.y));
            if (Physics.Raycast(ray, out hit, 1000, param.paintMask))
            {
                currentMousePos = hit.point;
                mouseHitPoint = hit;
            }
            else
            {
                mouseHitPoint = new RaycastHit();
            }
        }
        #endregion

        #region KeyboardInput
        public bool preventCustomUserHotkey(EventType type, EventModifiers codeModifier, KeyCode hotkey)
        {
            Event e = Event.current; // Grab the current event

            if (e.type == type && e.modifiers == codeModifier && e.keyCode == hotkey)
            {
                e.Use(); // We don't want to propagate the event            
                return true;
            }
            return false;
        }

        /// <summary>
        /// Get the Input from the keyboard event
        /// </summary>
        void sceneInput()
        {
            if (preventCustomUserHotkey(EventType.scrollWheel, EventModifiers.Control, KeyCode.None))
            {
                if (currentEvent.delta.y > 0)
                {
                    param.size++;
                }
                else
                {
                    param.size--;
                    param.size = Mathf.Max(1, param.size);
                }
                this.Repaint();
            }
            else if (preventCustomUserHotkey(EventType.scrollWheel, EventModifiers.Alt, KeyCode.None))
            {
                if (currentEvent.delta.y > 0)
                {
                    param.density++;
                }
                else
                {
                    param.density--;
                    param.density = Mathf.Max(1, param.density);
                }
                this.Repaint();
            }
            else if (currentEvent.control && currentEvent.alt && (currentEvent.button == 0 && currentEvent.type == EventType.MouseDown))
            {
                param.mode = PaintMode.Forced;
                param.heightForced = currentMousePos.y;
                this.Repaint();
            }
            else if (currentEvent.control && (currentEvent.button == 0 && currentEvent.type == EventType.MouseDown))
            {
                // Active Paint
                isPainting = true;
                painting();
            }
            else if (isPainting && !currentEvent.control || (currentEvent.button != 0 || currentEvent.type == EventType.MouseUp))
            {
                lastPaintPos = Vector3.zero;
                // Disable Paint
                isPainting = false;
            }
            else if (isPainting && (currentEvent.type == EventType.mouseDrag))
            {
                // Paint
                painting();
            }
            else if (currentEvent.alt && currentEvent.control && currentEvent.keyCode == KeyCode.Z && currentEvent.type == EventType.keyDown)
            {
                cancel();
            }
        }

        /// <summary>
        /// Revert the last(or more) group painted 
        /// </summary>
        void cancel()
        {
            if (memory != null && memory.Count > 0)
            {
                int index = memory.Count - 1; // Get last group painted
				foreach (var obj in memory[index])
				{
					DestroyImmediate(obj);
				}
                memory[index].Clear();  // Clear the list containing the group
                memory.RemoveAt(index); // Remove the list
            }
        }
        #endregion

        #region Paint
        /// <summary>
        /// Paint a group of gameobject at the mouse position
        /// </summary>
        void painting()
        {
            if (param.objects != null && param.objects.Count > 0)
            {
                if (Vector3.Distance(lastPaintPos, currentMousePos) > param.size)
                {
                    lastPaintPos = currentMousePos;
                    drawPaint();
                }
            }
            else
            {
                Debug.LogWarning("Prefabs list is empty !");
            }
        }

        /// <summary>
        /// initialise the root containing all groups
        /// </summary>
        void initRootGameObject()
        {
            if (rootParent == null)
            {
                if (GameObject.Find(ROOT_PARENT_NAME))
                    rootParent = GameObject.Find(ROOT_PARENT_NAME);
                else
                    rootParent = new GameObject(ROOT_PARENT_NAME);
            }
        }

        /// <summary>
        /// Add a group to paint
        /// </summary>
        void drawPaint()
        {
            initRootGameObject();
            int localDensity = param.density;
            Vector3 dir = Quaternion.AngleAxis(Random.Range(0, 360), Vector3.up) * Vector3.right;
            Vector3[] spawnPoint = new Vector3[localDensity];
            List<GameObject> localMem = new List<GameObject>();

            paintNumber++;

            for (int i = 0; i < localDensity; i++)
            {
                // new direction
                dir = Quaternion.AngleAxis(UnityEngine.Random.Range(0, 360), Vector3.up) * Vector3.right;

                // use direction for new position
                Vector3 spawnPos = getSpawnPosition(dir, spawnPoint);
                if (spawnPos != Vector3.zero)
                {
                    spawnPoint[i] = spawnPos;
                    //create
                    GameObject obj = spawnObject(spawnPoint[i]);
                    if (obj) localMem.Add(obj);
                }
            }
            if (groups == null)
                groups = new List<GameObject>();
            if (memory == null)
                memory = new List<List<GameObject>>();
            if (localMem.Count > 0)
            {
                memory.Add(localMem);
            }
            else
            {
                paintNumber--;
            }
        }

        Vector3 getSpawnPosition(Vector3 direction, Vector3[] otherSpawn)
        {
            if (param.proximityCheck)
            {
                Vector3 tempPos;
                bool success;
                int maxLoop = 10;
                int currentLoop = 0;
                do
                {
                    success = true;
                    tempPos = ((direction * param.size * Random.Range(0.1f, 1.1f)) + currentMousePos);
                    foreach (var pos in otherSpawn)
                    {
                        if (pos != Vector3.zero && Vector3.Distance(tempPos, pos) < param.proximityDistance)
                        {
                            success = false;
                        }
                    }
                    currentLoop++;
                    if (currentLoop > maxLoop) return Vector3.zero;
                } while (!success);


                return tempPos;
            }
            else
            {
                return ((direction * param.size * Random.Range(0.1f, 1.1f)) + currentMousePos);
            }
        }

        /// <summary>
        /// Spawn a random gameobject from the list "objects"
        /// </summary>
        /// <param name="pos">Position to spawn</param>
        /// <param name="parent">Parent of the object</param>
        /// <returns>Return the spawned gameobject</returns>
        GameObject spawnObject(Vector3 pos)
        {

            int rndIndex = Random.Range(0, param.objects.Count);
            GameObject prefabObj = param.objects[rndIndex].prefab;
            GameObject go = null;
            if (prefabObj != null)
            {
                go = (GameObject)PrefabUtility.InstantiatePrefab(prefabObj);

                if (paintPosition)
                {
                    go.transform.rotation = paintPosition.rotation;
                    go.transform.up = paintPosition.up;
                }
                else
                {
                    go.transform.rotation = Quaternion.identity;
                }

                //RND Rotation
                if (param.rndRotationX) go.transform.Rotate(Vector3.right, Random.Range(0, 360));
                if (param.rndRotationY) go.transform.Rotate(Vector3.up, Random.Range(0, 360));
                if (param.rndRotationZ) go.transform.Rotate(Vector3.forward, Random.Range(0, 360));

                Vector2 scale = param.objects[rndIndex].scale;
                if (scale != Vector2.one && scale != Vector2.zero)
                {
                    go.transform.localScale *= Random.Range(scale.x, scale.y);
                }

                if (param.mode == PaintMode.Forced)
                {
                    go.transform.position = new Vector3(pos.x, param.heightForced, pos.z);
                }
                else
                {
                    go.transform.position = pos;
                }

                if (param.mode == PaintMode.Snap)
                {
                    DoubleRayCast(go, rndIndex);
                }
                if (go)
                {
                    addObjectToGroup(go, rndIndex);
                }
            }
            else
            {
                Debug.LogWarning("Empty Object in the list !");
            }
            return go;
        }

        void addObjectToGroup(GameObject obj, int index)
        {
            Transform parent = rootParent.transform.Find(GROUP_NAME + (param.addPrefabNameToGroup ? param.objects[index].customName : ""));
            if (parent == null)
            {
                parent = new GameObject(GROUP_NAME + (param.addPrefabNameToGroup ? param.objects[index].customName : "")).transform;
                parent.SetParent(rootParent.transform);
                groups.Add(parent.gameObject);
            }
            obj.transform.SetParent(parent);
        }

        #endregion

        #region Evolved Paint
        public bool layerContain(LayerMask mask, int layer)
        {
            return mask == (mask | (1 << layer));
        }

        void DoubleRayCast(GameObject obj, int index)
        {
            Vector3 position = obj.transform.position + obj.transform.up * param.maxYPosition;
            obj.transform.position = position;
            obj.SetActive(false);
            RaycastHit groundHit;
            
            if (Physics.Raycast(position, -obj.transform.up, out groundHit))
            {
                RaycastHit objectHit;
                if (layerContain(param.paintMask, groundHit.collider.gameObject.layer))
                {
                    obj.SetActive(true);
                    if (Physics.Raycast(groundHit.point, obj.transform.up, out objectHit) && obj.layer == objectHit.collider.gameObject.layer)
                    {
                        Vector3 newPos;
                        float differencialDistance = Vector3.Distance(objectHit.point, obj.transform.position);
                        newPos = groundHit.point + (obj.transform.up * differencialDistance);
                        obj.transform.position = newPos;
                        return;
                    }
                    //Debug.Log(obj.name+" "+objectHit.collider.name);
                }
            }

            // Should have returned before
            DestroyImmediate(obj);
			//Debug.Log("Could not find appropriate spawn position");
        }

        #endregion
    }
}


