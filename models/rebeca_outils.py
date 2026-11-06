# Outils "Rebeca" pour Blender : stickers sur la voiture + export / publication dans Îlot Zéro.
#
# Installation : Édition > Préférences > Add-ons > Installer depuis le disque > rebeca_outils.py
# Utilisation  : Vue 3D > barre latérale (touche N) > onglet "Rebeca".
#
# Les stickers sont des objets "sticker_<n>" enfants de l'empty "rebeca". Ils sont exportés dans
# models/rebeca.glb avec la voiture, et le jeu les garde tels quels.

bl_info = {
    "name": "Rebeca - stickers et publication",
    "author": "Îlot Zéro",
    "version": (1, 0, 0),
    "blender": (4, 2, 0),
    "location": "Vue 3D > Barre latérale (N) > Rebeca",
    "description": "Ajoute des stickers (images) sur la voiture Rebeca et publie le skin dans le jeu",
    "category": "3D View",
}

import os
import subprocess

import bmesh
import bpy
from bpy.props import FloatProperty, StringProperty
from bpy_extras.io_utils import ImportHelper
from mathutils import Matrix, Vector
from mathutils.bvhtree import BVHTree

NOM_RACINE = "rebeca"
NOM_CAISSE = "rebeca_caisse"
PREFIXE = "sticker_"
SUBDIV = 24
TAILLE_MAX_TEXTURE = 1024
MESSAGE_COMMIT = "Skin Rebeca : stickers mis à jour"


# ---------------------------------------------------------------- utilitaires

def _popup(context, titre, lignes, icone="INFO"):
    def draw(self, _ctx):
        for l in lignes:
            self.layout.label(text=l)
    context.window_manager.popup_menu(draw, title=titre, icon=icone)


def _chemins():
    """(dossier du .blend, racine du dépôt) calculés depuis l'emplacement du fichier .blend."""
    fichier = bpy.data.filepath
    if not fichier:
        return None, None
    dossier = os.path.dirname(os.path.abspath(fichier))
    depot = os.path.dirname(dossier) if os.path.basename(dossier) == "models" else dossier
    return dossier, depot


def _stickers():
    return [o for o in bpy.data.objects if o.name.startswith(PREFIXE) and o.type == "MESH"]


def _prochain_nom():
    n = 1
    while bpy.data.objects.get(f"{PREFIXE}{n}"):
        n += 1
    return f"{PREFIXE}{n}"


def _point_sur_caisse(context, caisse):
    """Point + normale sur la carrosserie : près du curseur 3D, sinon au centre de la vue."""
    dg = context.evaluated_depsgraph_get()
    bvh = BVHTree.FromObject(caisse, dg)
    mw = caisse.matrix_world
    mwi = mw.inverted()
    nmat = mw.to_3x3().inverted().transposed()

    curseur = context.scene.cursor.location
    loc, nrm, _i, dist = bvh.find_nearest(mwi @ curseur)
    if loc is not None and dist < 0.25:
        return mw @ loc, (nmat @ nrm).normalized()

    rv3d = getattr(context.space_data, "region_3d", None) if context.space_data else None
    if rv3d is not None:
        vm = rv3d.view_matrix.inverted()
        oeil = vm.translation
        if not rv3d.is_perspective:
            oeil = rv3d.view_location + (vm.to_3x3() @ Vector((0, 0, 10.0)))
        direction = (rv3d.view_location - oeil).normalized()
        loc, nrm, _i, _d = bvh.ray_cast(mwi @ oeil, (mwi.to_3x3() @ direction).normalized())
        if loc is not None:
            return mw @ loc, (nmat @ nrm).normalized()
        loc, nrm, _i, _d = bvh.find_nearest(mwi @ rv3d.view_location)
        if loc is not None:
            return mw @ loc, (nmat @ nrm).normalized()
    return curseur.copy(), Vector((0, 0, 1))


def _orientation(normale):
    n = normale.normalized()
    haut = Vector((1, 0, 0)) if abs(n.z) > 0.85 else Vector((0, 0, 1))  # capot/toit : haut vers l'avant
    haut = (haut - n * haut.dot(n)).normalized()
    x = haut.cross(n).normalized()
    return Matrix((x, haut, n)).transposed().to_4x4()


def _materiau_sticker(nom, image):
    mat = bpy.data.materials.new(nom)
    mat.use_nodes = True
    nt = mat.node_tree
    bsdf = next(n for n in nt.nodes if n.type == "BSDF_PRINCIPLED")
    tex = nt.nodes.new("ShaderNodeTexImage")
    tex.image = image
    tex.extension = "CLIP"
    tex.location = (bsdf.location.x - 350, bsdf.location.y)
    nt.links.new(tex.outputs["Color"], bsdf.inputs["Base Color"])
    nt.links.new(tex.outputs["Alpha"], bsdf.inputs["Alpha"])
    bsdf.inputs["Roughness"].default_value = 0.35
    if hasattr(mat, "surface_render_method"):
        try:
            mat.surface_render_method = "BLENDED"
        except TypeError:
            pass
    if hasattr(mat, "blend_method"):
        try:
            mat.blend_method = "BLEND"
        except TypeError:
            pass
    mat.use_backface_culling = True
    return mat


def _maillage_plan(nom, largeur, hauteur):
    me = bpy.data.meshes.new(nom)
    bm = bmesh.new()
    uv = bm.loops.layers.uv.new("UVMap")
    grille = []
    for j in range(SUBDIV + 1):
        ligne = []
        for i in range(SUBDIV + 1):
            u, v = i / SUBDIV, j / SUBDIV
            ligne.append(bm.verts.new(((u - 0.5) * largeur, (v - 0.5) * hauteur, 0.0)))
        grille.append(ligne)
    for j in range(SUBDIV):
        for i in range(SUBDIV):
            f = bm.faces.new((grille[j][i], grille[j][i + 1], grille[j + 1][i + 1], grille[j + 1][i]))
            for boucle in f.loops:
                co = boucle.vert.co
                boucle[uv].uv = (co.x / largeur + 0.5, co.y / hauteur + 0.5)
    bm.to_mesh(me)
    bm.free()
    return me


# ---------------------------------------------------------------- opérateurs

class REBECA_OT_ajouter_sticker(bpy.types.Operator, ImportHelper):
    """Choisir une image et la coller sur la carrosserie comme sticker"""
    bl_idname = "rebeca.ajouter_sticker"
    bl_label = "Ajouter un sticker"
    bl_options = {"REGISTER", "UNDO"}

    filter_glob: StringProperty(default="*.png;*.jpg;*.jpeg;*.webp", options={"HIDDEN"})

    def execute(self, context):
        caisse = bpy.data.objects.get(NOM_CAISSE)
        racine = bpy.data.objects.get(NOM_RACINE)
        if caisse is None or racine is None:
            self.report({"ERROR"}, "Objets 'rebeca' / 'rebeca_caisse' introuvables dans la scène")
            return {"CANCELLED"}
        if context.object and context.object.mode != "OBJECT":
            bpy.ops.object.mode_set(mode="OBJECT")
        try:
            image = bpy.data.images.load(self.filepath, check_existing=False)
        except RuntimeError as e:
            self.report({"ERROR"}, f"Image illisible : {e}")
            return {"CANCELLED"}
        try:
            image.pack()
        except RuntimeError:
            pass
        l_px, h_px = image.size[:]
        if l_px == 0 or h_px == 0:
            self.report({"ERROR"}, "Image vide")
            return {"CANCELLED"}

        nom = _prochain_nom()
        image.name = nom
        largeur = context.scene.rebeca_taille_sticker
        hauteur = largeur * h_px / l_px

        ob = bpy.data.objects.new(nom, _maillage_plan(nom, largeur, hauteur))
        ob.data.materials.append(_materiau_sticker(nom, image))
        coll = racine.users_collection[0] if racine.users_collection else context.scene.collection
        coll.objects.link(ob)

        point, normale = _point_sur_caisse(context, caisse)
        ob.matrix_world = Matrix.Translation(point + normale * 0.01) @ _orientation(normale)
        mw = ob.matrix_world.copy()
        ob.parent = racine
        ob.matrix_world = mw

        sw = ob.modifiers.new("Coller sur la caisse", "SHRINKWRAP")
        sw.target = caisse
        sw.wrap_method = "PROJECT"
        sw.use_project_z = True
        sw.use_negative_direction = True
        sw.use_positive_direction = True
        sw.project_limit = 0.3
        sw.offset = context.scene.rebeca_ecart_sticker
        try:
            sw.wrap_mode = "OUTSIDE_SURFACE"
        except (TypeError, AttributeError):
            pass

        for o in context.selected_objects:
            o.select_set(False)
        ob.select_set(True)
        context.view_layer.objects.active = ob
        self.report({"INFO"}, f"{nom} ajouté. Déplacez-le avec G, tournez avec R, agrandissez avec S.")
        return {"FINISHED"}


class REBECA_OT_supprimer_sticker(bpy.types.Operator):
    """Supprimer le sticker sélectionné (et son image)"""
    bl_idname = "rebeca.supprimer_sticker"
    bl_label = "Supprimer le sticker sélectionné"
    bl_options = {"REGISTER", "UNDO"}

    @classmethod
    def poll(cls, context):
        o = context.active_object
        return o is not None and o.name.startswith(PREFIXE)

    def execute(self, context):
        ob = context.active_object
        mats = [m for m in ob.data.materials if m]
        images = [n.image for m in mats if m.node_tree for n in m.node_tree.nodes
                  if n.type == "TEX_IMAGE" and n.image]
        me = ob.data
        bpy.data.objects.remove(ob)
        if me.users == 0:
            bpy.data.meshes.remove(me)
        for m in mats:
            if m.users == 0:
                bpy.data.materials.remove(m)
        for im in images:
            if im.users == 0:
                bpy.data.images.remove(im)
        return {"FINISHED"}


class REBECA_OT_selectionner_sticker(bpy.types.Operator):
    """Sélectionner ce sticker"""
    bl_idname = "rebeca.selectionner_sticker"
    bl_label = "Sélectionner"
    nom: StringProperty()

    def execute(self, context):
        ob = bpy.data.objects.get(self.nom)
        if ob is None:
            return {"CANCELLED"}
        if context.object and context.object.mode != "OBJECT":
            bpy.ops.object.mode_set(mode="OBJECT")
        for o in context.selected_objects:
            o.select_set(False)
        ob.select_set(True)
        context.view_layer.objects.active = ob
        return {"FINISHED"}


def exporter_glb(context):
    """Écrit models/rebeca.glb (voiture + roues + stickers). Renvoie (chemin_glb, erreur)."""
    dossier, _depot = _chemins()
    if dossier is None:
        return None, "Enregistrez d'abord le fichier .blend (dans le dossier models du jeu)."
    racine = bpy.data.objects.get(NOM_RACINE)
    if racine is None:
        return None, "Empty 'rebeca' introuvable."
    chemin = os.path.join(dossier, "rebeca.glb")

    if context.object and context.object.mode != "OBJECT":
        bpy.ops.object.mode_set(mode="OBJECT")
    ancienne_sel = list(context.selected_objects)
    ancien_actif = context.view_layer.objects.active

    # textures de stickers trop grandes : copie réduite le temps de l'export
    remplacements = []
    for st in _stickers():
        for m in st.data.materials:
            if not m or not m.node_tree:
                continue
            for n in m.node_tree.nodes:
                if n.type == "TEX_IMAGE" and n.image and max(n.image.size[:]) > TAILLE_MAX_TEXTURE:
                    orig = n.image
                    k = TAILLE_MAX_TEXTURE / max(orig.size[:])
                    copie = orig.copy()
                    copie.scale(max(1, int(orig.size[0] * k)), max(1, int(orig.size[1] * k)))
                    n.image = copie
                    remplacements.append((n, orig, copie))
    erreur = None
    try:
        for o in context.view_layer.objects:
            o.select_set(False)
        objets = [racine] + list(racine.children_recursive)
        for o in objets:
            if o.name in context.view_layer.objects:
                o.select_set(True)
        context.view_layer.objects.active = racine
        bpy.ops.export_scene.gltf(
            filepath=chemin,
            export_format="GLB",
            use_selection=True,
            export_apply=True,
            export_yup=True,
            export_materials="EXPORT",
            export_image_format="AUTO",
            export_texcoords=True,
            export_normals=True,
            export_cameras=False,
            export_lights=False,
            export_animations=False,
        )
    except Exception as e:  # noqa: BLE001 - on veut afficher toute erreur à l'utilisateur
        erreur = f"Échec de l'export : {e}"
    finally:
        for n, orig, copie in remplacements:
            n.image = orig
            bpy.data.images.remove(copie)
        for o in context.view_layer.objects:
            o.select_set(o in ancienne_sel)
        context.view_layer.objects.active = ancien_actif
    return (None if erreur else chemin), erreur


class REBECA_OT_exporter(bpy.types.Operator):
    """Écrire models/rebeca.glb sans rien publier"""
    bl_idname = "rebeca.exporter"
    bl_label = "Exporter seulement (sans publier)"

    def execute(self, context):
        chemin, erreur = exporter_glb(context)
        if erreur:
            _popup(context, "Rebeca", [erreur], "ERROR")
            return {"CANCELLED"}
        _popup(context, "Rebeca", [f"Exporté : {chemin}"])
        return {"FINISHED"}


class REBECA_OT_publier(bpy.types.Operator):
    """Exporter models/rebeca.glb puis l'envoyer sur le dépôt git du jeu (add, commit, push)"""
    bl_idname = "rebeca.publier"
    bl_label = "Exporter et publier dans le jeu"

    def invoke(self, context, event):
        return context.window_manager.invoke_confirm(self, event)

    def execute(self, context):
        dossier, depot = _chemins()
        if dossier is None:
            _popup(context, "Rebeca", ["Enregistrez d'abord le fichier .blend."], "ERROR")
            return {"CANCELLED"}
        try:
            bpy.ops.file.pack_all()
        except RuntimeError:
            pass
        bpy.ops.wm.save_mainfile()
        chemin, erreur = exporter_glb(context)
        if erreur:
            _popup(context, "Rebeca", [erreur], "ERROR")
            return {"CANCELLED"}
        blend = os.path.abspath(bpy.data.filepath)
        rel_glb = os.path.relpath(chemin, depot)
        rel_blend = os.path.relpath(blend, depot)
        etapes = [
            ["git", "-C", depot, "add", rel_glb, rel_blend],
            ["git", "-C", depot, "commit", "-m", MESSAGE_COMMIT],
            ["git", "-C", depot, "push"],
        ]
        for cmd in etapes:
            try:
                r = subprocess.run(cmd, capture_output=True, text=True, timeout=180)
            except Exception as e:  # noqa: BLE001
                _popup(context, "Rebeca : échec de la publication", [f"{' '.join(cmd[3:])} : {e}"], "ERROR")
                return {"CANCELLED"}
            if r.returncode != 0:
                sortie = (r.stdout + "\n" + r.stderr).strip().splitlines()[-6:]
                if cmd[3] == "commit" and any("nothing to commit" in l or "rien à valider" in l for l in sortie):
                    _popup(context, "Rebeca", ["Rien de nouveau à publier (aucun changement)."])
                    return {"FINISHED"}
                _popup(context, "Rebeca : échec de la publication",
                       [f"La commande git {cmd[3]} a échoué :"] + sortie, "ERROR")
                return {"CANCELLED"}
        _popup(context, "Rebeca",
               ["Publié ! Les joueurs qui ont Rebeca verront les stickers d'ici 1 à 2 minutes."])
        self.report({"INFO"}, "Publié !")
        return {"FINISHED"}


# ---------------------------------------------------------------- panneau

class REBECA_PT_panneau(bpy.types.Panel):
    bl_label = "Rebeca - stickers"
    bl_idname = "REBECA_PT_panneau"
    bl_space_type = "VIEW_3D"
    bl_region_type = "UI"
    bl_category = "Rebeca"

    def draw(self, context):
        lay = self.layout
        sc = context.scene

        box = lay.box()
        box.label(text="Comment faire :", icon="INFO")
        col = box.column(align=True)
        col.label(text="1. Shift + clic droit sur la voiture")
        col.label(text="   pour y placer le curseur 3D.")
        col.label(text="2. Cliquez « Ajouter un sticker »")
        col.label(text="   et choisissez une image.")
        col.label(text="3. G = déplacer, R = tourner, S = taille.")
        col.label(text="   Le sticker épouse la carrosserie.")
        col.label(text="4. « Exporter et publier dans le jeu ».")

        lay.prop(sc, "rebeca_taille_sticker")
        lay.prop(sc, "rebeca_ecart_sticker")
        lay.operator("rebeca.ajouter_sticker", icon="IMAGE_DATA")

        stickers = _stickers()
        if stickers:
            box = lay.box()
            box.label(text=f"Stickers ({len(stickers)}) :")
            for st in stickers:
                ligne = box.row(align=True)
                op = ligne.operator("rebeca.selectionner_sticker", text=st.name,
                                    icon="RESTRICT_SELECT_OFF", depress=st.select_get())
                op.nom = st.name
            lay.operator("rebeca.supprimer_sticker", icon="TRASH")

        lay.separator()
        col = lay.column(align=True)
        col.scale_y = 1.4
        col.operator("rebeca.publier", icon="EXPORT")
        lay.operator("rebeca.exporter", icon="FILE_TICK")
        _dossier, depot = _chemins()
        if depot:
            lay.label(text=f"Dépôt : {depot}", icon="FILE_FOLDER")
        else:
            lay.label(text="Fichier .blend pas encore enregistré", icon="ERROR")


CLASSES = (
    REBECA_OT_ajouter_sticker,
    REBECA_OT_supprimer_sticker,
    REBECA_OT_selectionner_sticker,
    REBECA_OT_exporter,
    REBECA_OT_publier,
    REBECA_PT_panneau,
)


def register():
    bpy.types.Scene.rebeca_taille_sticker = FloatProperty(
        name="Taille du sticker", description="Largeur des nouveaux stickers (mètres)",
        default=0.5, min=0.02, max=4.0, unit="LENGTH")
    bpy.types.Scene.rebeca_ecart_sticker = FloatProperty(
        name="Écart à la carrosserie", description="Distance entre le sticker et la peinture",
        default=0.004, min=0.0, max=0.05, unit="LENGTH")
    for c in CLASSES:
        bpy.utils.register_class(c)


def unregister():
    for c in reversed(CLASSES):
        bpy.utils.unregister_class(c)
    del bpy.types.Scene.rebeca_taille_sticker
    del bpy.types.Scene.rebeca_ecart_sticker


if __name__ == "__main__":
    register()
