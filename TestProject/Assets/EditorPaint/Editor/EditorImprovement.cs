using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace EditorSpace
{
    public static class EditorImprovement
    {
        public static void Row(System.Action action, GUIStyle s)
        {
            EditorGUILayout.BeginHorizontal(s);
            action();
            EditorGUILayout.EndHorizontal();
        }

        public static void Row(System.Action action)
        {
            EditorGUILayout.BeginHorizontal();
            action();
            EditorGUILayout.EndHorizontal();
        }

        public static void Column(System.Action action, GUIStyle s)
        {
            EditorGUILayout.BeginVertical(s);
            action();
            EditorGUILayout.EndVertical();
        }

        public static void Column(System.Action action)
        {
            EditorGUILayout.BeginVertical();
            action();
            EditorGUILayout.EndVertical();
        }

        public static void View(ref Vector2 value, System.Action action, params GUILayoutOption[] opt)
        {
            value = GUILayout.BeginScrollView(value);
            action();
            EditorGUILayout.EndScrollView();
        }

        public static string Write
        {
            set { EditorGUILayout.LabelField(value); }
        }

        public static void Indent(System.Action action, int count)
        {
            EditorGUI.indentLevel += count;
            action();
            EditorGUI.indentLevel -= count;
        }

        public static bool ToggleGroup(bool value, string name, int indent, System.Action action, GUIStyle opt)
        {
            Column(() =>
            {
                value = EditorGUILayout.Foldout(value, name, true);
                if (value)
                {
                    Indent(() =>
                    {
                        action();
                    }, indent);
                }
            }, opt);
            return value;
        }

        public static bool ToggleGroup(bool value, string name, int indent, System.Action action)
        {
            Column(() =>
            {
                value = EditorGUILayout.Foldout(value, name, true);
                if (value)
                {
                    Indent(() =>
                    {
                        action();
                    }, indent);
                }
            });
            return value;
        }
    }
}


