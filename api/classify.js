export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).end();

  const { text } = req.body;
  if (!text) return res.json({ catId: 1 });

  try {
    const r = await fetch('https://api.anthropic.com/v1/messages', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': process.env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01'
      },
      body: JSON.stringify({
        model: 'claude-haiku-4-5-20251001',
        max_tokens: 5,
        messages: [{
          role: 'user',
          content: `Clasifica esta respuesta a "¿A qué te comprometes para ganar como equipo?" en UNA categoría.
Responde SOLO con el número (1–8), sin texto adicional.

1. Comunicación – escucha, claridad, retroalimentación, transparencia
2. Confianza – honestidad, coherencia, vulnerabilidad, palabra cumplida
3. Responsabilidad – ownership, cumplimiento, rendición de cuentas, seguimiento
4. Colaboración – apoyo mutuo, trabajo conjunto, eliminar silos, sinergia
5. Visión compartida – alineación, propósito común, claridad de objetivos
6. Desarrollo del equipo – aprendizaje, mentoría, feedback de crecimiento
7. Gestión del conflicto – diálogo difícil, acuerdos, manejo de tensiones
8. Reconocimiento y bienestar – celebración, motivación, cuidado, equilibrio

Respuesta: "${text.slice(0, 300)}"

Número:`
        }]
      })
    });
    const d = await r.json();
    const n = parseInt((d.content?.[0]?.text || '').replace(/\D/g, ''));
    res.json({ catId: n >= 1 && n <= 8 ? n : 1 });
  } catch (e) {
    res.json({ catId: 1 });
  }
}