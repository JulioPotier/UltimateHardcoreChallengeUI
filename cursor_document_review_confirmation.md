# Document review confirmation
_Exported on 5/5/2026 at 09:22:31 GMT+2 from Cursor (3.2.16)_

---

**User**

@cursor_interface_utilisateur_initiale_u.md lit ça et dis moi quand c'est OK on continue

---

**Cursor**

Lecture du fichier mentionné.



J’ai lu `cursor_interface_utilisateur_initiale_u.md` (export Cursor du 4 mai 2026). Voici où ça en est et ce que ça implique pour la suite.

## Contenu du fichier

C’est un **journal de conversation** : specs du projet UHCC (addon WoW Classic Era 1.15.8, Lua/TOC, textes en anglais), puis une longue série d’itérations (minimap, fenêtre Blizzard, onglets, colonnes, Spent avec icônes, données `UHCC.TABS` / `UHCC.OPTIONS`, sections Gear, bugfixes minimap/slider, etc.).

## État décrit à la fin du fichier

D’après la **dernière réponse enregistrée** dans le MD :

- Le **2ᵉ onglet** (*Weapons & Services*) a des **sections** **Weapons / Bags / Services**, avec **une section par colonne** (1 / 2 / 3), via le même mécanisme que pour *Gear & Quality* + un champ optionnel `column` sur les items `section` et la logique dans `buildTabPage`.

Le fichier **s’arrête là** : il n’y a pas de message utilisateur après cette étape dans l’export.

## C’est OK pour continuer ?

**Oui.** J’ai la vision du fil : UI minimap + fenêtre, données structurées, sections, Spent (sans logique métier complète de coût cumulé sauf si c’est déjà branché), pas de persistance des coches pour l’instant.

Pour la suite, les suites **logiques** mentionnées ou implicites dans le log seraient notamment :

- Même logique de **sections** pour **Professions & Talents** et **Zones & Dungeons** (ou placeholders).
- **`UHCC.optionById`**, calcul **Spent** à partir des choix, puis **sauvegarde** (`SavedVariables` / per character selon ton choix).
- Remplacer les placeholders *Zone X* / etc. quand tu auras les données.

Tu peux enchaîner avec la **prochaine tâche précise** (ex. « sections pour l’onglet 3 » ou « persistance »).  
**Note :** je suis en **mode Ask** : je peux expliquer et guider, mais pas modifier les fichiers. Pour que j’applique les changements dans le repo, passe en **mode Agent**.

**Résumé :** lecture OK, contexte aligné avec le MD — **on peut continuer** dès que tu indiques la prochaine étape (et le mode Agent si tu veux du code appliqué).

---

**User**

les labels des onglets doivent apparaitre en entier.

---

**Cursor**

Examinant comment les onglets sont créés et dimensionnés dans l'addon.



Corrigeant le dimensionnement des onglets : `GetTextWidth()` peut être 0 ou trop petit sur Classic, ce qui fait que `if tab:GetTextWidth() then` empêche parfois `SetWidth` et laisse des onglets trop étroits. Nous mesurerons la largeur via le `FontString` et forcerons une largeur suffisante.



Voici ce qui posait problème et ce qui a été changé.

## Cause

Les onglets utilisaient `PanelTemplates_TabResize` puis :

```lua
if tab.GetTextWidth and tab:GetTextWidth() then
  tab:SetWidth(tab:GetTextWidth() + 40)
end
```

Sur Classic, **`GetTextWidth()` peut être 0** (ou très petit) au moment où le code tourne. En Lua, **`0` est considéré comme faux**, donc **`SetWidth` n’était jamais appelé** et les onglets restaient à la largeur par défaut du template → texte coupé.

## Correctif

Une fonction locale **`sizeTabButtonToFullLabel`** :

1. Remet le `FontString` de l’onglet en **largeur libre** (`SetWidth(0)`) pour mesurer tout le texte.
2. Désactive le retour bizarre sur espaces (`SetNonSpaceWrap(false)`).
3. Appelle toujours **`PanelTemplates_TabResize`** pour le rendu Blizzard des textures.
4. Mesure la largeur avec **`FontString:GetStringWidth()`** (repli sur `GetTextWidth()` si besoin).
5. Applique **`tab:SetWidth(...)`** de façon **systématique** (plus de `if` sur une valeur pouvant être 0), avec **20 px de marge de chaque côté** (équivalent à l’ancien `+ 40`).

Tu peux faire un `/reload` : les libellés du type **Weapons & Services**, **Professions & Talents**, **Zones & Dungeons** devraient s’afficher en entier. Si le bloc d’onglets chevauche le compteur « Spent », on pourra décaler ce bloc ou élargir un peu la fenêtre dans un prochain pas.

---

**User**

@UltimateHardcoreChallengeUI.lua:582 remplace "gear_rules" par "gear_quest"

---

**Cursor**

Remplaçant les deux occurrences pour garder la cohérence entre `sectionTitles` et l'option associée.



Remplaçant la clé restante dans `sectionColumns`.



C’est fait. **`gear_rules`** a été renommé en **`gear_quest`** partout :

1. **`sectionTitles`** : `gear_quest = "Quest Gear"` (l. 582)  
2. **`sectionColumns`** : `gear_quest = 2` (anciennement `gear_rules`, l. 588)  
3. **Option « Wear Quest Gear »** : `category = "gear_quest"` (l. 165)

Comme ça, la section « Quest Gear » reste alignée avec la catégorie des données.

---

**User**

"quest gear" section is correctlt on col 3 (number 2) but at the bottom, can we automacially add same col numbers below each other?

---

**Cursor**

Examinant comment les colonnes et les sections sont gérées dans `buildTabPage`.



Corrigeant `setColumnStart` : lorsque `line > candidate`, le code passait systématiquement au bloc suivant, ce qui déplaçait « Quest Gear » en bas. Si on est déjà dans la même colonne, il faut continuer à empiler sans changer de bloc.



Voici ce qui se passait et ce qui a été modifié.

## Comportement avant

`setColumnStart(2)` calculait le début de la colonne 2 dans le bloc courant (`candidate = 30` pour le premier bloc). Dès que **`line` était déjà plus grand** (parce que les lignes « Accessories » avaient déjà rempli la colonne 2), le code considérait qu’on avait « dépassé » cette colonne et **passait au bloc suivant** → la section « Quest Gear » repartait tout en bas.

## Comportement maintenant

On regarde la **colonne réelle** de la ligne courante (`currentCol` à partir de `line % perBlock`). Si **`line > candidate`** mais **`currentCol == targetCol`**, on est **toujours en train de remplir la même colonne** : on **ne change pas `line`**, donc la nouvelle section (titre + cases) s’empile **juste sous** le contenu déjà dans cette colonne.

Les onglets du type *Weapons & Services* (colonnes 0 / 1 / 2 distinctes) ne changent pas : on ne saute de bloc que lorsqu’on **change** de colonne alors qu’on a déjà dépassé le début de la colonne cible dans le bloc actuel.

Un `/reload` devrait montrer « Quest Gear » directement sous « Accessories » dans la 3ᵉ colonne, sans grand vide en bas.

---

**User**

in settings tag, there is no prices, we wont use the same table format, we should not concat labels then. fix it to "Annoy me" with a description like "The addon will try to prevent you from doing thing you shouldn't by annoying you to the max"

---

**Cursor**

Examinant comment l'onglet Settings et les options sont construits.



Ajout du champ `description` à l'option, construction dédiée du spec pour l'onglet Settings, et rendu en liste simple dans `buildTabPage`.



Corrigeant le calcul vertical pour éviter chevauchements et espacements incohérents.



Voici ce qui a été fait :

## Données (`UHCC.OPTIONS`)

- L’entrée **Annoy me** a un champ **`description`** (texte en anglais, avec **« things »** pour un anglais correct ; tu avais écrit « thing »).
- **Aucun prix** n’est ajouté pour cet onglet (le flux qui concatène `formatCostSilver` ne s’applique plus à Settings).

## `buildSpecForTab`

- Pour **`tabKey == "settings"`**, on construit tout de suite un spec dédié avec des items **`settings_checkbox`** (`label`, `description`, `option`, `opts` si besoin), puis **`return`** — plus de grille multi-colonnes ni sections pour cet onglet.

## `buildTabPage`

- Nouveau type **`settings_checkbox`** : une ligne **checkbox + titre** (`GameFontNormalLarge`), en dessous une **description** (`GameFontHighlightSmall`, largeur 820, retour à la ligne).
- Hauteur du scroll : **`max(grille habituelle, settingsCursorY + marge)`** pour que l’onglet Settings ait assez de place.

En jeu : onglet **Settings** → **Annoy me** avec le paragraphe d’explication en dessous, sans « - Free » ni icônes d’argent. Pour d’autres réglages plus tard, il suffit d’ajouter des options `tab = "settings"` avec **`description`** ; on pourra étendre le spec (par ex. `settings_slider`) si tu en as besoin.

---

**User**

pourquoi les labels sont coupés? Les onnglets ne peuvent pas être plus larges ??

---

**Cursor**

Examinant le dimensionnement des onglets et les causes possibles de troncature.



Identifiant le problème : `PanelTemplates_UpdateTabs` réapplique souvent le style des onglets et peut réduire la largeur du texte ; `GetStringWidth()` sur le FontString du template peut sous-estimer la largeur réelle. Nous allons mesurer le libellé avec un FontString hors écran, réappliquer la largeur après chaque changement d'onglet, et élargir légèrement la fenêtre.



## Pourquoi les libellés étaient coupés

1. **Largeur du texte mesurée sur le mauvais objet**  
   Le `FontString` du template `CharacterFrameTabButtonTemplate` a souvent une **largeur max** imposée par Blizzard. Avec `SetWidth(0)` ça aide, mais après `PanelTemplates_TabResize` / changement d’onglet, **`GetStringWidth()` peut encore refléter une zone trop étroite**, donc une largeur de bouton trop petite → texte tronqué.

2. **`PanelTemplates_UpdateTabs`**  
   À chaque clic d’onglet, l’API **réapplique** le style actif/inactif des onglets. Ça peut **revenir à des largeurs par défaut** ou reserrer le texte. Si on ne **recalcule** la largeur qu’à la création, le problème revient dès qu’on change d’onglet.

## Ce qui a été changé

- **Mesure sur un `FontString` hors écran** (`GameFontNormalLarge`) avec le texte complet : pas de plafond du template ; utilisation de **`GetUnboundedStringWidth`** si l’API l’expose, sinon **`GetStringWidth`**.
- **Après chaque `PanelTemplates_UpdateTabs`**, une boucle **re-dimensionne tous les onglets** (`UHCC_MainFrameTab1` …) avec la même logique, pour que rien ne soit coupé en changeant d’onglet.
- **Marges un peu plus larges** (`TAB_LABEL_PAD = 28`) et largeur minimale de bouton **84 px**.
- **Fenêtre élargie** : **920 → 1040** pour laisser de la place aux 5 onglets qui se chevauchent un peu (`RIGHT, -15`) et au bloc « Spent ».

Les onglets **peuvent être plus larges** : c’est bien `tab:SetWidth(...)` qui fixe la largeur ; la limite venait surtout de la mesure et des resets Blizzard, pas d’un plafond absolu dans notre code. Si tu veux encore plus de marge, on peut monter `TAB_LABEL_PAD` ou la largeur de la fenêtre.

---

**User**

presque, au chargement ils sont encore coupés et étroits. Au clic, ils s'allongent tous, trop, et au survol je vois un décalage de design. corrige ou donne moi une autre solution pour ces onglets/pages

---

**Cursor**

Examinant le code des onglets et les interactions avec les templates Blizzard.



Remplaçant les onglets Blizzard (`CharacterFrameTabButtonTemplate` + `PanelTemplates`) par une bande d'onglets personnalisée : largeur uniforme calculée d'après les deux polices (normal / surbrillance), pas de saut au clic ni de changement de police au survol.



Voici ce qui posait problème et ce qui a été mis en place.

## Pourquoi ça coinçait

Le couple **`CharacterFrameTabButtonTemplate`** + **`PanelTemplates_*`** recalcule tout le temps textures, polices actif/inactif et largeurs du texte. D’où : texte trop étroit au premier affichage, puis **tous les onglets qui se réétirent** après `UpdateTabs`, et au survol **changement de police / hitbox** → impression de décalage.

## Nouvelle approche : bande d’onglets maison

- **Plus de template d’onglet Blizzard** ni `PanelTemplates_SetTab` / `UpdateTabs` / `SetNumTabs` sur cette fenêtre.
- **Boutons classiques** (`CreateFrame("Button")` sans template) avec :
  - fond **BACKGROUND** (gris / doré selon sélection),
  - surbrillance **ADD** légère au survol (sans changer la police au hover),
  - **`SetHighlightFontObject` = `GameFontNormalSmall`** comme le normal → **pas de saut** au survol,
  - **`SetPushedTextOffset(0, 0)`** pour éviter le texte qui bouge au clic.
- **Largeur unique pour tous les onglets** : on mesure chaque libellé avec **`GameFontNormalSmall`** et **`GameFontHighlightSmall`** (celle de l’onglet sélectionné), on prend le max, + marge. Comme la largeur ne change plus au clic, **plus d’effet « tout s’allonge »**.

L’onglet actif se voit surtout au **fond** et à la **couleur du texte** (surbrillance), style sobre mais stable.

## Bonus

- Suppression de la ligne **`s = 30`** dans `SetSpentCopper`, qui forçait l’argent à 30 au lieu de la valeur calculée.

Tu peux `/reload` : les libellés doivent être lisibles dès l’ouverture, sans extension bizarre au clic ni glitch au survol. Si tu veux un rendu **plus proche des onglets Blizzard** (textures `PaperDoll` en 3 parties), on pourra les recoller sur ces boutons en gardant la même logique de taille fixe.

---

**User**

hoo pas mal ! réduit la largeur de la fenetre, on garde nos 3 colonnes d'input tout de même.

---

**Cursor**

Repérant les largeurs fixées pour la fenêtre et les colonnes.



Réduisant la largeur de la fenêtre et recalculant les positions des colonnes pour conserver trois colonnes exploitables dans la zone scrollable.



Introduisant une constante de largeur et calculant automatiquement les trois colonnes à partir de la zone scrollable.



Voici ce qui a été changé.

## Fenêtre

- **`MAIN_FRAME_WIDTH = 960`** (au lieu de 1040), hauteur **560** inchangée.
- La fenêtre utilise **`f:SetSize(MAIN_FRAME_WIDTH, MAIN_FRAME_HEIGHT)`**.

## Trois colonnes

- Les abscisses ne sont plus en dur `{ 8, 300, 592 }` : elles viennent de la **largeur utile du scroll**  
  `innerScrollW = MAIN_FRAME_WIDTH - 64`  
  (24 px pour les bords du contenu `12+12`, 40 px pour les marges du `ScrollFrame` `10+30`).
- **Pas** de `colPitch` : `(innerScrollW - 16) / 3` en entier, avec **8 px** de marge à gauche → trois bandes **à peu près égales** (~293 / ~293 / ~302 px pour 960).

## Settings

- Largeur du texte de description : **`innerScrollW - 48`** (au lieu de 820 fixe), pour rester dans la zone utile.

Pour modifier la largeur plus tard, il suffit d’ajuster **`MAIN_FRAME_WIDTH`** en haut du fichier : les colonnes et la description suivront tout seuls.

---

**User**

la fenetre n'est au plus devant (onTop) qu'elle devrait, je vois d'autres éléments passer par dessus, ramène là au devant au max lors de son ouverture.

---

**Cursor**

Renforçant le strata et le niveau du cadre principal, et réappliquant `Raise()` à chaque ouverture.



Voici ce qui a été mis en place :

## Comportement

1. **`SetFrameStrata("FULLSCREEN_DIALOG")`**  
   Strata très haut (au-dessus de la plupart des fenêtres, listes, cadres « MEDIUM » / « HIGH », etc.). On évite **`TOOLTIP`** pour ne pas recouvrir les bulles d’aide du jeu de façon systématique.

2. **`SetFrameLevel(500)`**  
   Niveau élevé dans ce strata pour passer devant d’autres fenêtres au même strata.

3. **`SetToplevel(true)`**  
   Un clic sur la fenêtre la remonte au premier plan dans son strata.

4. **`OnShow`**  
   À chaque affichage, on réapplique strata + niveau et **`Raise()`**, au cas où un autre addon aurait remonté ses frames entre-temps.

5. **`ToggleMainFrame`**  
   Avant **`Show()`**, on force encore strata + niveau, puis **`Raise()`** après l’ouverture.

Après **`/reload`**, l’UI UHCC devrait rester nettement plus au premier plan. Si quelque chose passe encore par-dessus, indique lequel (ex. une fenêtre de quête plein écran) : on pourra monter au strata **`TOOLTIP`** uniquement si tu acceptes de passer au-dessus des tooltips.

---

**User**

Pour l'onglet "Professions & Talents" il faut aussi des sections, utilise "Professions" pour les 5 coches et "Talents" pour le range des points de talents. Aussi, ajoute un flag dans @UltimateHardcoreChallengeUI.lua:202  qui indique que même si c'est 0 il ne faut pas disabled ni autococher.

---

**Cursor**

Examinant la structure des options « professions » et la logique `isFree`.



Ajout des sections « Professions » / « Talents », extension de la logique d'injection de section aux sliders, et introduction du flag `noFreeLock`.



Rendant `noFreeLock` suffisant : retirer `isFree` sur cette ligne et faire en sorte que `optionLocksFreeChoice` retourne faux si `noFreeLock` est vrai.



Voici ce qui a été fait.

## Sections « Professions & Talents »

- Dans `buildSpecForTab`, pour `tabKey == "professions_talents"` :  
  `professions` → titre **Professions**, `talents` → titre **Talents**.
- L’injection de section accepte maintenant **`checkbox` et `range`**, pour afficher **Talents** avant le slider « Talent points » (catégorie `talents` déjà sur `TALENT-POINTS`).

## Flag `noFreeLock`

- **`Primary Profession 1`** : `cost = 0`, **`noFreeLock = true`**, plus de `isFree`.
- Helper **`optionLocksFreeChoice(opt)`** : si `opt.noFreeLock` → **pas** de case cochée forcée ni désactivée ; sinon comportement inchangé selon **`isFree`** pour les autres options.
- Utilisé pour les coches « normales » et pour **Settings** (`optionLocksFreeChoice` à la place de `opt.isFree` seul).

Le libellé garde **« - Free »** via `formatCostSilver(0)` ; seul le verrouillage UI est désactivé.

**Résumé** : `noFreeLock` = « ne jamais traiter comme option “Free” verrouillée », même si tu remets plus tard un `isFree` sur la même ligne (dans ce cas, `noFreeLock` prime).

---

**User**

Maintenant, chose importante, quand on coche ou quand on modifie un range slider, il faut ajouter à la valeur "spent" le montant de la valeur des coches. Exemple, le joueur coche "Cloth gear" et "Grey Gear" alors cela donne "00g 50s". puis on sauvegarde ces coche par personnage. la valeur est recalculée 1 fois au lancement de l'addon et mis à jour lors des coches/décoches (ça me semble bien, ou alors on le calcule autrement ? je te laisse voir) je rappelle que ce qui est dans "settings" n'a rien à voir, on s'en occupe plus tard, MAIS tu peux aussi sauvegarder l'état de la coche "annoy me" (mets la grisée pour le moment et ajoute en fin de label " - Under dev")

---

**Cursor**

Examinant comment « Spent », la base de données et les options sont structurés dans le projet.



Je suis en **mode Ask** : je ne peux pas modifier les fichiers. Voici une façon cohérente de faire, alignée sur ton code actuel.

## Unité `cost` et lien avec « Spent »

Dans `formatCostSilver`, un `cost` entier est décomposé en **or** et **argent** ainsi : `gold = floor(cost/100)`, `silver = cost % 100` (voir `formatCostSilver` dans `UltimateHardcoreChallengeUI.lua`).  
Donc **30** = 0 or + 30 argent, **20** = 0 or + 20 argent → **50** « unités d’affichage » = **0 or 50 argent**, comme dans ton exemple.

`SetSpentCopper` / `formatGoldSilverFromCopper` utilisent le **cuivre WoW** (1 or = 10 000, 1 argent = 100). Pour afficher la même chose que tes libellés, il faut convertir ton `cost` en cuivre, par exemple :

```text
copper = floor(cost / 100) * 10000 + (cost % 100) * 100
```

(une fois par option cochée, puis somme).

## Règle métier « Spent »

- Parcourir **`UHCC.OPTIONS`** (ou un futur `UHCC.optionById`).
- **Inclure** uniquement les entrées dont `tab ~= "settings"` (Settings n’impacte pas Spent).
- **Checkbox** : si cochée et pas « verrouillée free » au sens UI si tu veux l’exclure du coût (les `isFree` cochées fixes ne devraient probablement **pas** ajouter de coût, elles sont déjà à 0 en général).
- **Range** (ex. `TALENT-POINTS`) : contribution typique = **`floor(valeurSlider) * opt.cost`** si `cost` est le prix **par point** (à toi de figer la sémantique dans les données ; aujourd’hui `cost = 100` = 1 or par point avec la formule ci‑dessus).

Une fonction du type **`UHCC_RecalculateSpent()`** qui somme tout ça puis appelle **`UHCC_MainFrame:SetSpentCopper(total)`** est la bonne pièce centrale.

## Recalcul au chargement vs à chaque clic

- **Recalcul complet à chaque changement** (coche/décoche/slider) : simple, robuste, largement suffisant avec le nombre d’options actuel.
- **Recalcul une fois au chargement** puis **mise à jour incrémentale** (soustraire l’ancien état, ajouter le nouveau) : un peu plus fragile si plusieurs champs touchent la même option ; pas nécessaire tant que tu restes sous quelques centaines d’options.

Donc oui : **recalcul au `ADDON_LOADED` / à l’ouverture de la fenêtre après application de la sauvegarde**, puis **`RecalculateSpent()` dans les handlers** `OnClick` des checkboxes et `OnValueChanged` des sliders, c’est une bonne approche.

## Sauvegarde par personnage

Aujourd’hui le `.toc` a seulement `## SavedVariables: UHCC_DB` → **global** (tous les persos partagent la même table).

Pour du **vrai par personnage** :

1. **`## SavedVariablesPerCharacter: UHCC_DB`** (ou un second nom, ex. `UHCC_CharDB`, si tu veux garder la minimap globale dans `UHCC_DB` global — dans ce cas deux lignes dans le `.toc` et deux tables).
2. Dans `ensureDB()` (ou équivalent), initialiser par ex.  
   `UHCC_DB.options = UHCC_DB.options or {}`  
   clé = **`checkboxId`** (ou `checkboxId` + valeur pour les sliders).
3. **Au build** (`buildTabPage`) : après création du widget, **`SetChecked` / `SetValue`** depuis `UHCC_DB.options[id]`.
4. **Sur changement** : écrire dans `UHCC_DB.options[id]` puis `RecalculateSpent()`.

Les placeholders Zones (coût 0) peuvent être sauvegardés aussi ; ils n’ajoutent rien au total.

## Settings / « Annoy me »

- **Spent** : ignorer toute option avec `tab == "settings"` dans la somme.
- **Persistance** : même table `UHCC_DB.options["SETTINGS-ANNOY"] = true/false` (ou clé dédiée `settings.annoy`).
- **UI** : dans le flux `settings_checkbox` (ou sur l’option), **forcer** `disabled`, label = **`Annoy me - Under dev`** (ou concat comme tu préfères), `SetChecked` depuis la DB. Tu peux retirer `optionLocksFreeChoice` pour cette ligne si tu forces tout en dur côté spec.

---

En résumé : une fonction de **conversion cost → cuivre**, une **`RecalculateSpent()`** appelée après chargement des états depuis la DB et après chaque interaction, exclusion explicite de **`settings`**, et **`SavedVariablesPerCharacter`** (ou schéma global indexé par GUID) pour la persistance.

Si tu veux que ce soit implémenté directement dans le dépôt, passe en **mode Agent** et on l’appliquera dans `UltimateHardcoreChallengeUI.lua` + `.toc`.

---

**User**

tu es en agent, fait le dev

---

**Cursor**

Implémentant la persistance par personnage, le recalcul de « Spent » et les réglages pour « Annoy me ».



Implémentation : mise à jour du `.toc`, ajout de `UHCC_CharDB`, des fonctions de conversion et de recalcul, intégration dans `buildSpecForTab` / `buildTabPage`, et correction de l'ordre d'initialisation.



Voici ce qui a été mis en place.

## `.toc`
- **`## SavedVariablesPerCharacter: UHCC_CharDB`** ajouté (à côté de `UHCC_DB` pour la minimap, toujours globale).

## Données perso (`UHCC_CharDB.options`)
- Clé = **`checkboxId`**, valeur = **`true`/`false`** pour les cases, **`nombre`** pour les sliders (ex. `TALENT-POINTS`).

## Conversion coût → cuivre WoW
- **`uhccCostToCopper(displayCost)`** : même logique que `formatCostSilver` (`floor(cost/100)` or, `cost % 100` argent affiché).

## **Spent**
- **`computeTotalSpentCopperFromCharDB()`** : parcourt `UHCC.OPTIONS`, ignore **`tab == "settings"`**, ignore les coches **verrouillées « free »** (`optionLocksFreeChoice`), additionne les coches cochées et **`cost * points`** pour les **range**.
- **`recalcSpentCopper()`** / **`UHCC.RecalculateSpent`** : met à jour `UHCC_MainFrame:SetSpentCopper`.
- Appel après création de la fenêtre (**`recalcSpentDisplay()`** à la place de `SetSpentCopper(0)`), et sur **chaque coche** ( **`HookScript("OnClick")`** ) et **slider** (`OnValueChanged`).

## État au chargement
- **`buildSpecForTab`** : coches normales = état lu avec **`getCharCheckboxState`** ; options **free verrouillées** inchangées.
- **Slider** : valeur initiale lue dans `UHCC_CharDB` (sinon `min`).
- **`ensureCharDB()`** au **`ADDON_LOADED`** et au début de **`createMainWindow`**.

## Settings / Annoy me
- Libellé : **`Annoy me - Under dev`**.
- **`opts = { checked = lu en DB, disabled = true }`** (grisée, pas d’interaction pour l’instant ; la valeur reste en base pour plus tard).

Exemple : **Cloth (30) + Grey (20)** → **5000 cuivre** → affichage **`00` or `50` argent** avec tes icônes actuelles.

Un **`/reload`** peut être nécessaire la première fois pour que WoW enregistre la nouvelle variable perso.

---

**User**

selon la classe du personnage, rend les coches "plate/mail/leather" non cochables car tout le monde ne peut pas tout porter

---

**Cursor**

Implémentant le masquage des types d'armure selon la classe du joueur (UnitClass). Vérification de la structure des options « gear_type ».



Ajout du mapping classe → types d'armure (WoW Classic), désactivation des coches impossibles à porter et nettoyage des sauvegardes invalides.



Voici ce qui a été ajouté.

## Règles d’armure (poids `cloth` / `leather` / `mail` / `plate`)

Table **`CLASS_ARMOR_ALLOWED`** d’après le **2ᵉ retour** de `UnitClass("player")` (`WARRIOR`, `MAGE`, etc.) :

| Classes | Tissu | Cuir | Maille | Plaques |
|--------|-------|------|--------|---------|
| Guerrier, Paladin, DK | ✓ | ✓ | ✓ | ✓ |
| Chasseur, Chaman | ✓ | ✓ | ✓ | ✗ |
| Voleur, Druide | ✓ | ✓ | ✗ | ✗ |
| Prêtre, Mage, Démoniste | ✓ | ✗ | ✗ | ✗ |

**`GEAR-NONE`** (`term == "none"`) reste toujours utilisable.

## Comportement

- **`isGearArmorTierOption`** : options **Gear tier** (`tab == "gear_quality"`, `category == "gear_type"`, coches, `term` ≠ `none`).
- Si la classe **ne peut pas** porter ce poids : **`opts = { checked = false, disabled = true }`** (comme les autres coches grisées).
- **`pruneInvalidGearArmorSelections()`** : remet à **`false`** en base les coches impossibles (évite un vieux perso avec « Plate » coché sur un mage).
- Appelée au **`createMainWindow`** après **`ensureCharDB()`**.
- **Spent** : les armures refusées ne comptent **jamais**, même si une valeur restait en base.

Les coches désactivées n’ont pas de **`HookScript("OnClick")`** (déjà le cas avec `cb:IsEnabled()`).

**Note jeu** : en Classic, chasseur/chaman portent la maille surtout **à partir du niveau 40** ; ici on ne regarde que la **classe** (pas le niveau). Si tu veux aussi bloquer la maille avant 40, il faudra un test sur `UnitLevel("player")` (à faire dans un second temps).

---

**User**

quand l'addon se lance pour la 1ere fois sur un personnage, on a 0 data. on va alors en ajouter une qui sert de flag pour indiquer que ce perso a reçu le premier chargement. aussi il faut une commande /UHCC reset qui demande une confirmation de supprimer les données de ce joueur et décoche tout car un joueur qui meurt et en recrée un avec le même nom aura un soucis. (sauf les grisées disabled)

---

**Cursor**

Ajout du flag de premier chargement, de la commande `/uhcc reset` avec popup de confirmation et du nettoyage de l'UI (recréation de la fenêtre).



Ajout de `resetCharChallengeData`, extension de `ensureCharDB` pour le flag `_uhccFirstAddonLoad`, enregistrement du popup et des slash commands.



Voici ce qui a été ajouté.

## Flag premier chargement (`UHCC_CharDB`)

- Dans **`ensureCharDB()`** : si **`UHCC_CharDB._uhccFirstAddonLoad`** est **`nil`** (nouveau perso / table vide), on le met à **`true`** une fois.
- Ce flag **n’est pas effacé** par **`/uhcc reset`** : il indique seulement que l’addon a déjà initialisé ce personnage ; le reset ne vide que **`UHCC_CharDB.options`**.

Tu peux t’en servir plus tard (`if UHCC_CharDB._uhccFirstAddonLoad then …`) pour migrations ou onboarding.

## `/uhcc reset` et `/UHCC reset`

- **`SLASH_UHCC1 = "/uhcc"`** et **`SLASH_UHCC2 = "/UHCC"`** → même handler.
- **`/uhcc reset`** ouvre **`StaticPopupDialogs["UHCC_RESET_CHARACTER"]`** (Oui / Non, Échap = annuler).
- **Oui** → **`resetCharChallengeData()`** :
  - remet **`UHCC_CharDB.options`** à une table vide ;
  - détruit **`UHCC.mainFrame`** (fermé + `SetParent(nil)` + `nil`) pour que la fenêtre soit **reconstruite** au prochain clic minimap avec tout décoché sauf ce qui est forcé par le spec (free lock, armure impossible à porter, Annoy grisé, etc.) ;
  - **`recalcSpentDisplay()`** ;
  - message dans le chat.
- **`/uhcc`** seul → rappel de la commande **`reset`**.

## API

- **`UHCC.ResetCharacterData()`** = même action que la validation du popup (pour tests / autres appels).

## Tooltip minimap

- Ligne ajoutée : **`/uhcc reset — clear this character's options`**.

---

**Note WoW** : les variables **par personnage** sont liées au personnage côté client, pas seulement au nom ; le cas « même nom » sur un autre perso est en général déjà un autre stockage. **`/uhcc reset`** sert surtout à **vider ce slot** après mort hardcore / reroll sur le **même** slot perso.

---

**User**

si lors du premier chargement le personnage n'est pas niveau 1, il faut montrer un warning lui indiquant qu'il vaut mieux commencer au niveau 1 et qu'il faudra cocher pour ne pas être ennuyé.

---

**Cursor**

Implémentant l'avertissement au premier chargement si le personnage n'est pas niveau 1 : vérification du code actuel de `ensureCharDB` et des popups.



Déclenchant l'avertissement uniquement pour un personnage vraiment vierge (aucune option enregistrée) lors de la première initialisation du flag, afin d'éviter d'afficher le popup aux joueurs ayant déjà des données.



Voici ce qui a été mis en place.

## Quand le message s’affiche

- **Première init** du perso pour l’addon : `_uhccFirstAddonLoad` passait de `nil` à `true` (comme avant).
- **Aucune option déjà enregistrée** : la table `UHCC_CharDB.options` est vide (vrai « 0 data », pas un vieux perso qui avait déjà des coches sans ce flag).
- **`_uhccNonLevel1AdviceSeen`** n’est pas encore défini.
- Après **2 s**, si **`UnitLevel("player") > 1`**, on affiche le popup et on enregistre **`_uhccNonLevel1AdviceSeen = true`** pour ne plus le montrer.

Ainsi, un joueur qui a déjà des entrées dans `options` (migration / ancienne version) ne reçoit pas ce warning à tort.

## Contenu du popup (FR)

- Titre **UHCC — Recommandation**
- Explication : pas niveau 1 → mieux vaut commencer au **niveau 1** pour le défi.
- Indication : dans **Settings**, il faudra **cocher** l’option prévue (quand elle sera dispo) pour **ne pas être ennuyé** par des rappels constants.
- Bouton **OK**.

## Fichier

- **`StaticPopupDialogs["UHCC_NON_LEVEL1_ADVICE"]`** ajouté au bloc des autres popups.
- Logique dans **`ensureCharDB()`** (timer **`C_Timer.After(2, …)`**).

`/uhcc reset` ne vide que **`options`** : les métadonnées **`_uhccFirstAddonLoad`** et **`_uhccNonLevel1AdviceSeen`** restent, donc le warning ne se rejoue pas après un reset (comportement cohérent avec « premier chargement »). Si tu veux le revoir après un reset, on pourra aussi effacer **`_uhccNonLevel1AdviceSeen`** dans **`resetCharChallengeData`**.

---

**User**

ajoute un écran de bienvenu (après ou derrière le warning s'il doit s'afficher) indiquant que le mode Ultimate Hardcore est activé.

---

**Cursor**

Examinant le code actuel des popups et du timer pour enchaîner correctement l'avertissement niveau et l'écran de bienvenue.



Déclarant `uhccShowWelcomePopup` en forward declaration, enchaînant le popup niveau vers le bienvenue, et affichant le bienvenue directement si niveau 1.



Voici ce qui a été mis en place.

## Popup **`UHCC_WELCOME`**
- Texte en français : mode **Ultimate Hardcore activé** pour ce personnage, rappel d’utiliser l’icône minimap pour les règles, « Bonne chance ».
- Bouton **OK**, même style que les autres popups.

## Enchaînement
1. **Perso vierge** (même logique qu’avant : `firstInit`, `options` vide, pas encore `_uhccWelcomeSeen`) → après **2 s** :
   - si **niveau > 1** et l’avis niveau **n’a pas déjà été vu** → **`UHCC_NON_LEVEL1_ADVICE`** ;
   - sinon → **`uhccShowWelcomePopup()`** directement (niveau 1 ou sans popup niveau).
2. **Après** l’avis niveau (**OK** ou **Annuler / Échap** via `OnCancel`) : **`_uhccNonLevel1AdviceSeen`**, puis **0,2 s** plus tard → **`UHCC_WELCOME`**.
3. **`uhccShowWelcomePopup`** pose **`_uhccWelcomeSeen = true`** puis affiche le bienvenue (une seule fois).

La condition pour lancer le flux utilise désormais **`not _uhccWelcomeSeen`** (plus seulement l’avis niveau), pour toujours finir par le bienvenue une fois le flux démarré.

## Technique
- **`local uhccShowWelcomePopup`** en tête, assignation **`uhccShowWelcomePopup = function() ... end`** juste après **`ensureCharDB`**, pour que le timer puisse l’appeler sans erreur de portée.

Si **Échap** sur l’avis niveau ne déclenche pas **`OnCancel`** sur ta version du client, dis-le et on pourra ajouter un 2ᵉ bouton ou un **`OnHide`**.

---

**User**

je suis niveau 44, j'ai fait /reload et je n'ai rien eu alors que c'est mon premier lancement techniquement

---

**Cursor**

Constat : le flux d'accueil ne se déclenchait que si `_uhccFirstAddonLoad == nil` (vrai uniquement au tout premier chargement). Après un `/reload`, ce flag est déjà sauvegardé — plus rien ne s'affichait. Nous corrigeons en basant le flux sur `_uhccWelcomeSeen` et en déclenchant après `PLAYER_ENTERING_WORLD` pour un `UnitLevel` fiable.



Supprimant la condition `firstInit` (elle n'est vraie qu'une seule fois avant sauvegarde) et déclenchant l'onboarding après `PLAYER_ENTERING_WORLD` pour garantir un niveau correct.



Vérifiant si le slider enregistre dans la DB au chargement et vide ainsi « virgin ».



Corrigeant le slider : `SetValue` déclenchait `OnValueChanged` et enregistrait `TALENT-POINTS` avant `PLAYER_ENTERING_WORLD`, ce qui vidait la condition « options vierges ».



Voici **pourquoi** tu ne voyais rien au `/reload`, et **ce qui a été corrigé**.

## 1. Condition `firstInit` (cause principale)

L’onboarding ne partait que si **`_uhccFirstAddonLoad == nil`**. Au **premier** chargement du jeu, ça passait à `true` et était **sauvegardé**. Après un **`/reload`**, ce n’était plus jamais `nil` → **plus aucun popup**, même si tu n’avais jamais vu le bienvenue.

**Changement** : l’onboarding ne dépend plus de ça. Il se base sur **`_uhccWelcomeSeen`** + options « vierges », et il est lancé après **`PLAYER_ENTERING_WORLD`** (niveau fiable en jeu).

## 2. Ordre de chargement : slider qui « salissait » la DB

`createMainWindow()` s’exécutait **avant** `PLAYER_ENTERING_WORLD`. Le **slider talents** appelait `OnValueChanged` sur **`SetValue(0)`** et écrivait **`TALENT-POINTS`** dans `UHCC_CharDB.options` → la table n’était plus vide → **`virginOptions`** devenait **false** → l’onboarding était **sauté**.

**Changement** : flag **`slider.UHCC_readyForPersist`** : pas d’écriture en base sur le **`SetValue`** initial ; uniquement quand le joueur bouge vraiment le slider (après `ready = true`).

## 3. Déclenchement explicite après le monde

Sur **`ADDON_LOADED`**, on enregistre **`PLAYER_ENTERING_WORLD`**, puis une fois ce event reçu : **`C_Timer.After(1.25, uhccScheduleOnboardingIfNeeded)`** pour enchaîner avis niveau → bienvenue comme avant.

---

En **niveau 44**, avec **`options` vide** et **`_uhccWelcomeSeen` absent**, tu devrais voir après connexion (~1,5–2,5 s) d’abord l’avis **niveau 1**, puis le **bienvenue**.

Si tu avais déjà **`_uhccWelcomeSeen = true`** en base (test précédent), efface-le ou fais un reset adapté pour retester. Si besoin d’une commande du style **`/uhcc onboarding`** pour forcer le flux en debug, on peut l’ajouter.

---

**User**

la commande "/UHCC reset" doit aussi reset cette popup de niveau, c'est le cas ?

---

**Cursor**

Non : `resetCharChallengeData` ne réinitialisait que `options` et la fenêtre. Nous allons effacer `_uhccNonLevel1AdviceSeen` et `_uhccWelcomeSeen`, remettre le garde-timer à false et relancer l'onboarding.



**Non**, ce n’était pas le cas avant : `/uhcc reset` ne touchait qu’à **`UHCC_CharDB.options`** (et à la fenêtre).

C’est **corrigé** : le reset efface aussi :
- **`_uhccNonLevel1AdviceSeen`**
- **`_uhccWelcomeSeen`**
- le flag de session **`uhccOnboardingTimerScheduled`** (pour pouvoir replanifier tout de suite)

Puis **`C_Timer.After(0.75, uhccScheduleOnboardingIfNeeded)`** relance le flux (avis niveau → bienvenue si besoin), sans oblige à `/reload`.

**Non remis à zéro** : **`_uhccFirstAddonLoad`** (métadonnée « addon déjà initialisé pour ce perso »), sauf si tu veux qu’on le vide aussi.

---

**User**

oui on reset tout

---

**Cursor**

Réinitialisant entièrement `UHCC_CharDB` (toutes les clés), puis réappliquant `ensureCharDB()` pour recréer une table propre.



Voici ce qui a été changé.

## `resetCharChallengeData`

- **`for k in pairs(UHCC_CharDB) do UHCC_CharDB[k] = nil end`** : vide **toutes** les entrées de la table perso (options, `_uhccFirstAddonLoad`, `_uhccWelcomeSeen`, `_uhccNonLevel1AdviceSeen`, etc.).
- Puis **`UHCC_CharDB.options = {}`** et **`ensureCharDB()`** pour remettre une base cohérente (dont **`_uhccFirstAddonLoad`** repassé à **`true`** au prochain passage, comme sur un perso neuf).
- **`uhccOnboardingTimerScheduled = false`** inchangé.
- Le **`C_Timer.After(0.75, uhccScheduleOnboardingIfNeeded)`** est conservé pour rejouer bienvenue / popup niveau si besoin.

## Textes

- Message chat : **« All character data for this addon was reset »**.
- Texte du **StaticPopup** de confirmation : précise que tout est effacé (options + popups / flags).

Toute **future** clé ajoutée sous `UHCC_CharDB` sera aussi supprimée par ce wipe.

---

**User**

ajoute la gear_quality "epic"!

---

**Cursor**

Ajout d'un palier « Quality Tier 6 » avec `term = "epic"`, placé après le violet (épique WoW).



C’est en place.

## Nouvelle option

- **`checkboxId`**: `QUALITY-EPIC`  
- **`label`**: `Quality Tier 6 - Epic Gear`  
- **`category`**: `gear_quality` (même section **Quality** que les autres paliers)  
- **`term`**: `epic`  
- **`cost`**: `20000` → **200 or** avec ton format actuel (au-dessus du violet à 100 or ; tu peux changer la valeur si tu veux un autre prix).

Elle est insérée **juste après** « Purple Gear » et **avant** les slots (Cloaks, etc.), donc l’ordre des tiers reste cohérent.

---

**User**

on écrit en anglais dans l'addon! je vois @UltimateHardcoreChallengeUI.lua:1213 @UltimateHardcoreChallengeUI.lua:1203 traduit

---

**Cursor**

Traduction des deux popups en anglais.



Voici ce qui a été modifié :

**`UHCC_WELCOME`** — texte en anglais : mode Ultimate Hardcore **enabled** pour ce personnage, utiliser le bouton minimap pour les règles, « Good luck! ».

**`UHCC_NON_LEVEL1_ADVICE`** — texte en anglais : titre **Recommendation**, personnage pas **level 1**, recommandation de **start at level 1**, puis mention de l’onglet **Settings** et de **check** la case pour éviter les rappels répétés.

Les codes couleur `|cffffcc00|…|r` et `|cff00ff00|…|r` sont inchangés. Si tu veux harmoniser d’autres chaînes françaises ailleurs dans le fichier, indique lesquelles.

---

**User**

le range des talents doit monter à 50 et non 40, erreur de ma part

---

**Cursor**

Mise à jour de `max` pour l'option « Talent points » : 40 → 50.



C’est fait. L’entrée **`TALENT-POINTS`** dans `UHCC.OPTIONS` a maintenant **`max = 50`** au lieu de `40`. Le slider lit `opt.max` depuis cette table, donc aucun autre endroit à modifier. Les valeurs déjà enregistrées (0–40) restent valides ; tu peux monter jusqu’à 50 après un `/reload`.

---

**User**

@c:\Users\Julio\Downloads\wow-zones.csv Voici les infos sur les zones. le fichier CSV contient 4 colonnes. La première est l'ID de la zone, la seconde est le nom de cette zone, la 3è le type de zone entre "zone,city,battleground" et la 4è le continent entre "Kalimdor, Eastern Kingdoms, Azeroth". Il faut en créer un tableau complet afi de pouvoir remplir l'onglet "Zones & Dungeons", il faut donc 3 sections sur 3 colonnes avec les 3 continents. Le prix de chaque zone est "3 gold"

---

**Cursor**

Examen du CSV et de la structure de l'addon pour l'onglet « Zones & Dungeons ».



Générant le tableau Lua à partir du CSV et mettant à jour `buildSpecForTab`. Coût : 3 or = 300 unités d'affichage (`floor(cost/100)` = 3).



Constat : plus de 15 zones par continent — le grille actuelle enchaîne la colonne suivante après 15 lignes. Nous augmentons `maxRows` pour l'onglet « Zones & Dungeons » afin que chaque continent tienne dans sa colonne.



Voici ce qui a été mis en place.

## `UHCC.WORLD_ZONES`
Tableau **49 entrées** (même contenu que ton CSV : zones, villes, champs de bataille), dans le même ordre que le fichier. Chaque ligne est `{ mapID, nom, type CSV, continent }`.

## Options « Zones & Dungeons »
- Génération à partir de `UHCC.WORLD_ZONES` : plus de placeholders Zone/City/Dungeon/Raid.
- **`checkboxId`** : `ZONE-<mapID>` (ex. `ZONE-1411`) — stable pour les SavedVariables.
- **`term`** : `tostring(mapID)` (ex. `"1411"`).
- **`cost = 300`** → **3 or** dans ton système (`floor(300/100) = 3`, voir commentaire ligne ~382).

## Sections sur 3 colonnes
Dans `buildSpecForTab`, pour `zones_dungeons` :
- **Kalimdor** → colonne 0  
- **Eastern Kingdoms** → colonne 1  
- **Azeroth** → colonne 2 (les 3 BG)

Les lignes sont regroupées par continent dans cet ordre (l’ordre **à l’intérieur** de chaque continent suit l’ordre d’apparition dans le CSV).

## Grille UI
Eastern Kingdoms a **25** cases ; la grille ne gardait que **15** lignes par colonne avant de passer à la colonne suivante. Pour l’onglet **« Zones & Dungeons »** uniquement, **`maxRows` passe à 30** afin que toute une colonne reste sous le bon titre.

---

**Note :** les anciennes cases `ZONE-01` … `RAID-05` ne correspondent plus aux nouveaux IDs ; les coches enregistrées pour ces IDs ne s’appliquent plus (les nouvelles clés sont `ZONE-1411`, etc.). Un **`/uhcc reset`** sur un perso de test évite tout mélange si tu avais déjà coché des placeholders.

Pour mettre à jour les zones plus tard, tu peux soit éditer **`UHCC.WORLD_ZONES`**, soit me dire si tu préfères charger le CSV depuis un fichier dans le dossier de l’addon (WoW ne lit pas `Downloads` au runtime).

---

**User**

Pour chaquecontinent, ajoute une section "Cities" pour chaque élément "city" et remplace le nom "Azeroth" par "Battlegrounds"

---

**Cursor**

Examinant la génération des options et `buildSpecForTab` pour séparer zones / villes et renommer « Azeroth » en « Battlegrounds ».



Séparant les zones et les villes par continent et renommant la colonne Azeroth en « Battlegrounds ».



Voici ce qui a été fait.

## Structure par continent

**Colonne Kalimdor**  
1. Section **Kalimdor** — entrées `zone` sur Kalimdor  
2. Section **Cities** — Orgrimmar, Thunder Bluff, Darnassus  

**Colonne Eastern Kingdoms**  
1. Section **Eastern Kingdoms** — zones EK  
2. Section **Cities** — Stormwind, Ironforge, Undercity  

**Colonne 2**  
- Section **Battlegrounds** (remplace l’intitulé *Azeroth*) — Alterac Valley, Warsong Gulch, Arathi Basin  

## Implémentation

- Les **catégories d’options** sont : `kalimdor_zones`, `kalimdor_cities`, `ek_zones`, `ek_cities`, `battlegrounds`.  
- L’ordre d’émission garde l’ordre du CSV **dans chaque seau** (même filtrage `zone` / `city` / `battleground`).  
- `checkboxId` / `term` par map restent identiques (`ZONE-1454`, etc.) — seule l’organisation de l’UI change.  

Si tu veux des titres de section distincts du type **Cities (Kalimdor)** au lieu de deux **Cities**, dis-le et on l’ajuste.

---

**User**

ok maintenant on va faire un test, si je n'ai pas coché la zone 1429 et que je suis dans cette zone, alors mon écran doit devenir totalement noir à 90% en fade sur 10 secondes (mais les éléments du jeu restent cliquable)avec un message rouge au centre de l'écran indiquant "You didn't purchased this zone 'Elwynn Forest', get out or purchase now". si le joueur sort ou coche la bonne coche, le message stoppe et l'écran redevient tout à fait normal en 3 secondes

---

**Cursor**

Implémentant un overlay plein écran non bloquant, synchronisé avec la carte actuelle et les options cochées. Examen du fichier pour l'intégration.



Implémentant l'overlay : construction de la table `mapId → option`, création du frame au chargement, et hook dans `recalcSpentDisplay`.



Ajout du code : insertion de la table de lookup, puis du module overlay complet.



Corrigeant la portée de la fonction : `local uhccZoneRestrictionOverlayUpdate` restait nil. Déplaçant la définition avant `recalcSpentDisplay` et simplifiant la création des textures.



Réorganisant le code : placer `local function uhccZoneRestrictionOverlayUpdate` avant `recalcSpentDisplay`, et convertir la fonction globale en locale.



Voici ce qui a été mis en place.

## Comportement

1. **Détection** – `C_Map.GetBestMapForUnit("player")` avec remontée vers les cartes **parentes** (`parentMapID`), pour coller à une entrée de `UHCC_ZONE_OPTION_BY_MAP_ID` (ex. sous-zones d’Elwynn → **1429**).

2. **Violation** – Si une option zone correspond à la carte actuelle et que la case **n’est pas** cochée dans les SavedVariables :
   - calque noir **jusqu’à 90 %** d’opacité en **10 s** ;
   - texte rouge centré :  
     `You haven't purchased this zone: 'Elwynn Forest'. Get out or purchase now.`  
     (formulation corrigée par rapport à « You didn't purchased ».)

3. **Clics** – Le frame plein écran a **`EnableMouse(false)`** pour que le jeu reste cliquable derrière.

4. **Fin** – En quittant la zone **ou** en cochant la bonne zone dans l’UI (via `recalcSpentDisplay()`), retour à la normale en **3 s** (fondu du noir + texte).

## Technique

- Table **`UHCC_ZONE_OPTION_BY_MAP_ID`** : `mapId` → option `zones_dungeons`.
- Frame **`UHCC_ZoneRestrictionOverlay`**, strate **`FULLSCREEN`**, mis à jour en **`OnUpdate`** + événements **`ZONE_CHANGED`**, **`ZONE_CHANGED_NEW_AREA`**, **`PLAYER_ENTERING_WORLD`**.
- **`recalcSpentDisplay()`** appelle **`uhccZoneRestrictionOverlayUpdate()`** pour réagir tout de suite au clic sur la case.

Pour tester : va en **Forêt d’Elwynn** sans cocher **Elwynn Forest** (1429) dans l’onglet Zones ; après `/reload`, le fondu doit démarrer. Si le fond reste noir sans correspondance de carte, dis-le (version client / instance) et on pourra ajuster la résolution de carte.

